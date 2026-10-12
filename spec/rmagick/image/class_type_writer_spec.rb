# frozen_string_literal: true

RSpec.describe Magick::Image, '#class_type=' do
  it 'does not allow setting to UndefinedClass' do
    image = described_class.new(20, 20)

    expect { image.class_type = Magick::UndefinedClass }
      .to raise_error(ArgumentError, 'Invalid class type specified.')
  end

  it 'raises an error when ImageMagick runs out of resources' do
    direct = described_class.new(20, 20)
    pseudo = described_class.new(20, 20)
    pseudo.class_type = Magick::PseudoClass
    resources = %i[area memory map disk]
    limits = resources.to_h { |resource| [resource, Magick.limit_resource(resource, 0)] }

    expect { direct.class_type = Magick::PseudoClass }.to raise_error(Magick::ImageMagickError)
    expect { pseudo.class_type = Magick::DirectClass }.to raise_error(Magick::ImageMagickError)
  ensure
    limits&.each { |resource, limit| Magick.limit_resource(resource, limit) }
  end
end
