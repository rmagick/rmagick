# frozen_string_literal: true

require 'tmpdir'

# Regression: Draw#enquote wrapped a value in double quotes without escaping an
# embedded quote, so a value could close the MVG token and have the rest of the
# string executed as further primitives -- including `image`, which reads an
# attacker-named file or URL into the rendered output. Draw#clip_path and
# Draw#encoding did not quote at all.
RSpec.describe Magick::Draw, '#fill' do
  it 'escapes a quote character in the value' do
    draw = described_class.new
    draw.fill('none" image Over 0,0 1,1 "/etc/passwd')

    expect(draw.inspect).to eq('fill "none\\" image Over 0,0 1,1 \\"/etc/passwd"')
  end

  it 'escapes a backslash so it cannot escape the closing quote' do
    draw = described_class.new
    draw.stroke('red\\')

    expect(draw.inspect).to eq('stroke "red\\\\"')
  end

  it 'quotes the clip-path and encoding names' do
    draw = described_class.new
    draw.clip_path('c image Over 0,0 1,1 "/etc/passwd"')
    draw.encoding('UTF-8 image Over 0,0 1,1 "/etc/passwd"')

    expect(draw.inspect.lines.map(&:chomp)).to eq(
      [
        'clip-path "c image Over 0,0 1,1 \\"/etc/passwd\\""',
        'encoding "UTF-8 image Over 0,0 1,1 \\"/etc/passwd\\""'
      ]
    )
  end

  it 'still passes an already quoted value through' do
    %w[red].each do |value|
      expect(described_class.new.tap { |d| d.fill(%("#{value}")) }.inspect).to eq(%(fill "#{value}"))
      expect(described_class.new.tap { |d| d.fill(%('#{value}')) }.inspect).to eq(%(fill '#{value}'))
      expect(described_class.new.tap { |d| d.fill("{#{value}}") }.inspect).to eq("fill {#{value}}")
    end
  end

  it 'leaves ordinary values alone' do
    ['red', '#ff0000', 'rgb(255,0,0)', 'none', 'DejaVu Sans', '/path/with space/font.ttf'].each do |value|
      expect(described_class.new.tap { |d| d.fill(value) }.inspect).to eq(%(fill "#{value}"))
    end
  end

  it 'does not let a style value inject an MVG primitive' do
    Dir.mktmpdir do |dir|
      secret = File.join(dir, 'secret.png')
      Magick::Image.new(80, 80) { |options| options.background_color = 'red' }.write(secret)

      image = Magick::Image.new(200, 120) { |options| options.background_color = 'white' }
      draw = described_class.new
      draw.fill(%(none" image Over 0,0 80,80 "#{secret}" "))
      draw.rectangle(0, 0, 1, 1)

      # The value is no longer a colour, so ImageMagick rejects it -- what must
      # not happen is the injected `image` primitive being executed.
      begin
        draw.draw(image)
      rescue Magick::ImageMagickError
        nil
      end

      drew_secret = image.export_pixels(0, 0, 200, 120, 'RGB').each_slice(3)
                         .any? { |red, green, blue| red > 50_000 && green < 15_000 && blue < 15_000 }
      expect(drew_secret).to be(false)
    end
  end
end
