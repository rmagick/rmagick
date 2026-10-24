# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Magick::Draw, '#text' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.text(50, 50, 'Hello world')
    expect(draw.inspect).to eq("text 50,50 'Hello world'")
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.text(50, 50, "Hello 'world'")
    expect(draw.inspect).to eq("text 50,50 \"Hello 'world'\"")
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.text(50, 50, 'Hello "world"')
    expect(draw.inspect).to eq("text 50,50 'Hello \"world\"'")
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.text(50, 50, "Hello 'world\"")
    expect(draw.inspect).to eq("text 50,50 {Hello 'world\"}")
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.text(50, 50, "Hello {'world\"")
    expect(draw.inspect).to eq("text 50,50 {Hello {'world\"}")
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.text(50, 50, '') }.to raise_error(ArgumentError)
    expect { draw.text('x', 50, 'Hello world') }.to raise_error(ArgumentError)
    expect { draw.text(50, 'x', 'Hello world') }.to raise_error(ArgumentError)
  end

  it 'escapes backslashes in the text' do
    draw = described_class.new
    draw.text(50, 50, 'Hello\\')
    expect(draw.inspect).to eq("text 50,50 'Hello\\\\'")

    draw = described_class.new
    draw.text(50, 50, "Hello 'world\\")
    expect(draw.inspect).to eq("text 50,50 \"Hello 'world\\\\\"")

    draw = described_class.new
    draw.text(50, 50, "Hello '\"world\\}")
    expect(draw.inspect).to eq("text 50,50 {Hello '\"world\\\\\\}}")
  end

  # Regression: the text was wrapped in quotes without escaping backslashes, so
  # ImageMagick's tokenizer read a backslash before the closing delimiter as an
  # escape, the token ran on, and the rest of the primitive list was parsed as
  # MVG. The injected `image` primitive then read an arbitrary file into the
  # rendered output.
  it 'does not let the text break out of the MVG token' do
    Dir.mktmpdir do |dir|
      secret = File.join(dir, 'secret.png')
      Magick::Image.new(60, 60) { |options| options.background_color = 'red' }.write(secret)

      drew_secret = lambda do |*texts|
        image = Magick::Image.new(200, 100) { |options| options.background_color = 'white' }
        draw = described_class.new
        texts.each_with_index { |text, i| draw.text(0, 10 + (i * 20), text) }
        draw.draw(image)
        image.export_pixels(0, 0, 200, 100, 'RGB').each_slice(3)
             .any? { |red, green, blue| red > 50_000 && green < 15_000 && blue < 15_000 }
      end

      primitive = %(image Over 0,0 0,0 "#{secret}")

      # A trailing backslash escaped the closing quote.
      expect(drew_secret.call('hello\\', primitive)).to be(false)
      # Such a string also matched the "text already quoted" fast path.
      expect(drew_secret.call("'hello\\'", primitive)).to be(false)
      # In the brace branch, \} closed the token early.
      expect(drew_secret.call(%(x'"\\} #{primitive}\n#))).to be(false)
    end
  end

  # Regression: the delimiter was chosen and escaped per Ruby character, but
  # ImageMagick's MVG tokenizer reads bytes. In Shift_JIS and similar encodings
  # a trail byte can equal a brace, so the brace token closed early and the rest
  # was parsed as MVG primitives.
  it 'does not let a non-UTF-8 text inject an MVG primitive' do
    # The leading quotes force the brace branch; Shift_JIS 0x81 0x7D ends in the
    # ASCII '}' (0x7D), which closes the brace token.
    text = (+"'\"\x81\x7D fill #00FF00 rectangle 0,0 200,120 ").force_encoding('Shift_JIS')

    image = Magick::Image.new(200, 120) { |options| options.background_color = 'white' }
    draw = described_class.new
    draw.text(0, 0, text)
    begin
      draw.draw(image)
    rescue Magick::ImageMagickError
      nil
    end

    centre = image.pixel_color(100, 60)
    injected = centre.green > 50_000 && centre.red < 15_000 && centre.blue < 15_000
    expect(injected).to be(false)
  end
end
