# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Magick::Image, '#get_pixels' do
  def interrupt(error)
    thread = Thread.new do
      Thread.current.report_on_exception = false
      yield
      nil
    rescue error
      nil
    end
    Thread.pass until thread.status == 'sleep' || !thread.alive?
    thread.raise(error) if thread.alive?
    thread.join
    nil
  end

  it 'works' do
    image = described_class.new(20, 20)

    pixels = image.get_pixels(0, 0, image.columns, 1)
    expect(pixels).to be_instance_of(Array)
    expect(pixels.length).to eq(image.columns)
    expect(pixels.all?(Magick::Pixel)).to be(true)

    expect { image.get_pixels(0,  0, -1, 1) }.to raise_error(RangeError)
    expect { image.get_pixels(0,  0, image.columns, -1) }.to raise_error(RangeError)
    expect { image.get_pixels(0,  0, image.columns + 1, 1) }.to raise_error(RangeError)
    expect { image.get_pixels(0,  0, image.columns, image.rows + 1) }.to raise_error(RangeError)
  end

  it 'supports CMYK color' do
    image = described_class.read(File.join(FIXTURE_PATH, 'cmyk.jpg')).first
    pixel = image.get_pixels(0, 0, 1, 1).first

    # convert cmyk.jpg -format '%[pixel:p{1,1}]' info:-
    # => cmyk(49,181,1,183)
    expect(pixel.cyan).to    equal(49  * 257)
    expect(pixel.magenta).to equal(181 * 257)
    expect(pixel.yellow).to  equal(1   * 257)
    expect(pixel.black).to   equal(183 * 257)
  end

  it 'get proper alpha value' do
    image = described_class.new(1, 1)

    pixel = Magick::Pixel.new
    pixel.red   = 12 * 257
    pixel.green = 34 * 257
    pixel.blue  = 56 * 257
    pixel.alpha = 78 * 257

    image.alpha(Magick::SetAlphaChannel)
    image.store_pixels(0, 0, 1, 1, [pixel])

    temp_file_path = File.join(Dir.tmpdir, 'rmagick_get_pixels.png')
    image.write(temp_file_path)

    image2 = described_class.read(temp_file_path).first
    pixel = image2.get_pixels(0, 0, 1, 1).first

    expect(pixel.red).to   equal(12 * 257)
    expect(pixel.green).to equal(34 * 257)
    expect(pixel.blue).to  equal(56 * 257)
    expect(pixel.alpha).to be_within(78 * 257).of(1)
  end

  it 'reads a negative value of an HDRI image' do
    image = described_class.new(1, 1)
    image.pixel_color(0, 0, Magick::Pixel.new(-Magick::QuantumRange, 0, 0))
    expected = Magick::Magick_features.include?('HDRI') ? -Magick::QuantumRange : 0

    expect(image.get_pixels(0, 0, 1, 1).first.red).to eq(expected)
  end

  it 'releases the pixel cache when the thread is interrupted' do
    cancelled = Class.new(StandardError)
    GC.start
    baseline = Magick.resource_usage(:memory)
    image = described_class.new(1000, 1000)
    interrupt(cancelled) { image.get_pixels(0, 0, 999, 999) }
    image.destroy!
    3.times { GC.start }

    expect(Magick.resource_usage(:memory)).to be <= baseline
  end
end
