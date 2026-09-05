# frozen_string_literal: true

require 'tmpdir'

# Regression: Draw#fill_opacity, #stroke_opacity and #opacity returned any
# String ending in '%' unchanged and interpolated it into the MVG program, so a
# value carrying a newline had the rest of the string executed as further
# primitives -- including `image`, which reads an attacker-named file into the
# rendered output.
RSpec.describe Magick::Draw, '#to_opacity' do
  let(:methods) { { fill_opacity: 'fill-opacity', stroke_opacity: 'stroke-opacity', opacity: 'opacity' } }
  let(:valid) { ['0%', '20%', '50%', '100%', '0.5%', '.5%', '1.0e-05%', '1E2%'] }
  let(:invalid) { ['101%', '1e3%', '-1%', '+50%', ' 50%', '%', 'xxx%', '1e%', '1.2.3%', "50%\n", "50\n%"] }
  let(:injection) { "1%\nfill red\nrectangle 0,0 20,20\nfill-opacity 1%" }

  it 'accepts a percentage' do
    methods.each do |method, keyword|
      valid.each do |value|
        expect(described_class.new.tap { |d| d.public_send(method, value) }.inspect).to eq("#{keyword} #{value}")
      end
    end
  end

  it 'rejects a percentage that is out of range or malformed' do
    methods.each_key do |method|
      invalid.each do |value|
        expect { described_class.new.public_send(method, value) }.to raise_error(ArgumentError)
      end
    end
  end

  it 'rejects a percentage carrying further MVG primitives' do
    methods.each_key do |method|
      expect { described_class.new.public_send(method, injection) }.to raise_error(ArgumentError)
    end
  end

  it 'validates the value itself rather than a derived one' do
    klass = Class.new(String) do
      def chomp(*) = '50'
    end

    expect { described_class.new.fill_opacity(klass.new(injection)) }.to raise_error(ArgumentError)
  end

  it 'does not let an opacity value inject an MVG primitive' do
    Dir.mktmpdir do |dir|
      secret = File.join(dir, 'secret.png')
      Magick::Image.new(80, 80) { |options| options.background_color = 'red' }.write(secret)

      image = Magick::Image.new(200, 120) { |options| options.background_color = 'white' }
      draw = described_class.new

      begin
        draw.fill_opacity(%(1%\nimage Over 0,0 80,80 "#{secret}"\nfill-opacity 1%))
        draw.rectangle(0, 0, 1, 1)
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
