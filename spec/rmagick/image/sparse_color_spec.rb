# frozen_string_literal: true

RSpec.describe Magick::Image, '#sparse_color' do
  it 'works' do
    image = described_class.new(100, 100)
    args = [30, 10, 'red', 10, 80, 'blue', 70, 60, 'lime', 80, 20, 'yellow']
    # ensure good calls work
    Magick::SparseColorMethod.values do |v|
      next if v == Magick::UndefinedColorInterpolate

      expect { image.sparse_color(v, *args) }.not_to raise_error
    end
    args << Magick::RedChannel
    expect { image.sparse_color(Magick::VoronoiColorInterpolate, *args) }.not_to raise_error
    args << Magick::GreenChannel
    expect { image.sparse_color(Magick::VoronoiColorInterpolate, *args) }.not_to raise_error
    args << Magick::BlueChannel
    expect { image.sparse_color(Magick::VoronoiColorInterpolate, *args) }.not_to raise_error

    # bad calls
    args = [30, 10, 'red', 10, 80, 'blue', 70, 60, 'lime', 80, 20, 'yellow']
    # invalid method
    expect { image.sparse_color(1, *args) }.to raise_error(TypeError)
    # missing arguments
    expect { image.sparse_color(Magick::VoronoiColorInterpolate) }.to raise_error(ArgumentError)
    args << 10 # too many arguments
    expect { image.sparse_color(Magick::VoronoiColorInterpolate, *args) }.to raise_error(ArgumentError)
    args.shift
    args.shift # too few
    expect { image.sparse_color(Magick::VoronoiColorInterpolate, *args) }.to raise_error(ArgumentError)

    args = [30, 10, 'red', 10, 80, 'blue', 70, 60, 'lime', 80, '20', 'yellow']
    expect { image.sparse_color(Magick::VoronoiColorInterpolate, *args) }.to raise_error(TypeError)
  end

  it 'uses black of a CMYK color' do
    image = described_class.new(2, 1)
    image.colorspace = Magick::CMYKColorspace
    black = Magick::Pixel.new(0, 0, 0)
    black.black = Magick::QuantumRange

    result = image.sparse_color(Magick::VoronoiColorInterpolate, 0, 0, black)

    expect(result.get_pixels(0, 0, 2, 1).map(&:black)).to eq([Magick::QuantumRange, Magick::QuantumRange])
  end
end
