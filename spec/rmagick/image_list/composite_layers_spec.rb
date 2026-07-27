# frozen_string_literal: true

RSpec.describe Magick::ImageList, '#composite_layers' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])
    image_list2 = described_class.new # intersection is 5..9
    image_list2 << image_list[5]
    image_list2 << image_list[6]
    image_list2 << image_list[7]
    image_list2 << image_list[8]
    image_list2 << image_list[9]

    expect { image_list.composite_layers(image_list2) }.not_to raise_error
    Magick::CompositeOperator.values do |op|
      expect { image_list.composite_layers(image_list2, op) }.not_to raise_error
    end

    expect { image_list.composite_layers(image_list2, Magick::ModulusAddCompositeOp, 42) }.to raise_error(ArgumentError)
  end

  # The receiver is deep-copied with clone_imagelist() before the source list is
  # resolved, and the copy is owned by no Ruby object, so every one of these has
  # to release it on the way out.
  it 'raises given a source list it cannot use' do
    image_list = described_class.new
    image_list << Magick::Image.new(20, 20)

    destroyed = described_class.new
    destroyed << Magick::Image.new(20, 20)
    destroyed.first.destroy!

    expect { image_list.composite_layers(described_class.new) }.to raise_error(ArgumentError)
    expect { image_list.composite_layers('x') }.to raise_error(Magick::ImageMagickError)
    expect { image_list.composite_layers(destroyed) }.to raise_error(Magick::DestroyedImageError)
  end
end
