RSpec.describe Magick::Image, '#sparse_color' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    img = Magick::Image.new(100, 100)
    args = [30, 10, 'red', 10, 80, 'blue', 70, 60, 'lime', 80, 20, 'yellow']
    # ensure good calls work
    Magick::SparseColorMethod.values do |v|
      next if v == Magick::UndefinedColorInterpolate

      expect { img.sparse_color(v, *args) }.not_to raise_error
    end
    args << Magick::RedChannel
    expect { img.sparse_color(Magick::VoronoiColorInterpolate, *args) }.not_to raise_error
    args << Magick::GreenChannel
    expect { img.sparse_color(Magick::VoronoiColorInterpolate, *args) }.not_to raise_error
    args << Magick::BlueChannel
    expect { img.sparse_color(Magick::VoronoiColorInterpolate, *args) }.not_to raise_error

    # bad calls
    args = [30, 10, 'red', 10, 80, 'blue', 70, 60, 'lime', 80, 20, 'yellow']
    # invalid method
    expect { img.sparse_color(1, *args) }.to raise_error(TypeError)
    # missing arguments
    expect { img.sparse_color(Magick::VoronoiColorInterpolate) }.to raise_error(ArgumentError)
    args << 10 # too many arguments
    expect { img.sparse_color(Magick::VoronoiColorInterpolate, *args) }.to raise_error(ArgumentError)
    args.shift
    args.shift # too few
    expect { img.sparse_color(Magick::VoronoiColorInterpolate, *args) }.to raise_error(ArgumentError)

    args = [30, 10, 'red', 10, 80, 'blue', 70, 60, 'lime', 80, '20', 'yellow']
    expect { img.sparse_color(Magick::VoronoiColorInterpolate, *args) }.to raise_error(TypeError)
  end
end
