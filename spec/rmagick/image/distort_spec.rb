# frozen_string_literal: true

RSpec.describe Magick::Image, '#distort' do
  it 'works' do
    image = described_class.new(200, 200)

    expect { image.distort(Magick::AffineDistortion, [2, 60, 2, 60, 32, 60, 32, 60, 2, 30, 17, 35]) }.not_to raise_error
    expect { image.distort(Magick::AffineProjectionDistortion, [1, 0, 0, 1, 0, 0]) }.not_to raise_error
    expect { image.distort(Magick::BilinearDistortion, [7, 40, 4, 30, 4, 124, 4, 123, 85, 122, 100, 123, 85, 2, 100, 30]) }.not_to raise_error
    expect { image.distort(Magick::PerspectiveDistortion, [7, 40, 4, 30,   4, 124, 4, 123, 85, 122, 100, 123, 85, 2, 100, 30]) }.not_to raise_error
    expect { image.distort(Magick::ScaleRotateTranslateDistortion, [28, 24, 0.4, 0.8 - 110, 37.5, 60]) }.not_to raise_error
    expect { image.distort(Magick::ScaleRotateTranslateDistortion, [28, 24, 0.4, 0.8 - 110, 37.5, 60], true) }.not_to raise_error
    expect { image.distort }.to raise_error(ArgumentError)
    expect { image.distort(Magick::AffineDistortion) }.to raise_error(ArgumentError)
    expect { image.distort(1, [1]) }.to raise_error(TypeError)
    expect { image.distort(Magick::AffineDistortion, [2, 60, 2, 60, 32, 60, 32, 60, 2, 30, 17, 'x']) }.to raise_error(TypeError)
  end

  it 'raises an error when the options block destroys the image' do
    image = described_class.new(20, 20)

    expect { image.distort(Magick::ScaleRotateTranslateDistortion, [0]) { image.destroy! } }.to raise_error(Magick::DestroyedImageError)
  end

  it 'raises an error when converting the points destroys the image' do
    image = described_class.new(20, 20)
    points = Object.new
    points.define_singleton_method(:to_a) { image.destroy! && [0] }

    expect { image.distort(Magick::ScaleRotateTranslateDistortion, points) }.to raise_error(Magick::DestroyedImageError)

    image = described_class.new(20, 20)
    point = Struct.new(:image) do
      def to_f
        image.destroy! && 0.0
      end
    end.new(image)

    expect { image.distort(Magick::ScaleRotateTranslateDistortion, [point]) }.to raise_error(Magick::DestroyedImageError)
  end
end
