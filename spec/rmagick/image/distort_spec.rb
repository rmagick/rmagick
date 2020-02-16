RSpec.describe Magick::Image, '#distort' do
  it 'works' do
    img = described_class.new(200, 200)

    expect { img.distort(Magick::AffineDistortion, [2, 60, 2, 60, 32, 60, 32, 60, 2, 30, 17, 35]) }.not_to raise_error
    expect { img.distort(Magick::AffineProjectionDistortion, [1, 0, 0, 1, 0, 0]) }.not_to raise_error
    expect { img.distort(Magick::BilinearDistortion, [7, 40, 4, 30, 4, 124, 4, 123, 85, 122, 100, 123, 85, 2, 100, 30]) }.not_to raise_error
    expect { img.distort(Magick::PerspectiveDistortion, [7, 40, 4, 30,   4, 124, 4, 123, 85, 122, 100, 123, 85, 2, 100, 30]) }.not_to raise_error
    expect { img.distort(Magick::ScaleRotateTranslateDistortion, [28, 24, 0.4, 0.8 - 110, 37.5, 60]) }.not_to raise_error
    expect { img.distort(Magick::ScaleRotateTranslateDistortion, [28, 24, 0.4, 0.8 - 110, 37.5, 60], true) }.not_to raise_error
    expect { img.distort }.to raise_error(ArgumentError)
    expect { img.distort(Magick::AffineDistortion) }.to raise_error(ArgumentError)
    expect { img.distort(1, [1]) }.to raise_error(TypeError)
    expect { img.distort(Magick::AffineDistortion, [2, 60, 2, 60, 32, 60, 32, 60, 2, 30, 17, 'x']) }.to raise_error(TypeError)
  end
end
