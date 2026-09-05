# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Magick::Draw, '#pattern' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.pattern('hat', 0, 10.5, 20, '20') {}
    expect(draw.inspect).to eq("push defs\npush pattern hat 0 10.5 20 20\npush graphic-context\npop graphic-context\npop pattern\npop defs")
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.pattern('hat', 'x', 0, 20, 20) {} }.to raise_error(ArgumentError)
    expect { draw.pattern('hat', 0, 'x', 20, 20) {} }.to raise_error(ArgumentError)
    expect { draw.pattern('hat', 0, 0, 'x', 20) {} }.to raise_error(ArgumentError)
    expect { draw.pattern('hat', 0, 0, 20, 'x') {} }.to raise_error(ArgumentError)
    expect { draw.pattern(Object.new, 'x', 0, 20, 20) }.to raise_error(TypeError)
  end

  it 'accepts an identifier-like name' do
    ['hat', 'a-b', 'a_b', 'a.b', '0', 'Pattern1'].each do |name|
      draw = described_class.new
      draw.pattern(name, 0, 0, 20, 20) {}
      expect(draw.inspect.lines[1].chomp).to eq("push pattern #{name} 0 0 20 20")
    end
  end

  it 'rejects a name that would not survive as a single MVG token' do
    ['a b', "a\nb", "a\tb", 'a"b', "a'b", 'a{b', 'a#b', 'a,b', 'a:b', 'a(b', '', "hat\n"].each do |name|
      draw = described_class.new
      expect { draw.pattern(name, 0, 0, 20, 20) {} }.to raise_error(ArgumentError)
      expect(draw.inspect).to eq('(no primitives defined)')
    end
  end

  it 'does not let the name inject an MVG primitive' do
    Dir.mktmpdir do |dir|
      secret = File.join(dir, 'secret.png')
      Magick::Image.new(80, 80) { |options| options.background_color = 'red' }.write(secret)

      image = Magick::Image.new(200, 120) { |options| options.background_color = 'white' }
      draw = described_class.new

      begin
        draw.pattern(%(a 0 0 1 1\npop pattern\npop defs\nimage Over 0,0 80,80 "#{secret}"\npush defs\npush pattern b), 0, 0, 20, 20) {}
        draw.draw(image)
      rescue ArgumentError, Magick::ImageMagickError
        nil
      end

      high = Magick::QuantumRange * 0.75
      low = Magick::QuantumRange * 0.25
      drew_secret = image.export_pixels(0, 0, 200, 120, 'RGB').each_slice(3)
                         .any? { |red, green, blue| red > high && green < low && blue < low }
      expect(drew_secret).to be(false)
    end
  end
end
