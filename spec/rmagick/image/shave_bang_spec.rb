# frozen_string_literal: true

RSpec.describe Magick::Image, '#shave' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.shave!(5, 5)
    expect(result).to be(image)

    image.freeze
    expect { image.shave!(2, 2) }.to raise_error(FrozenError)
  end

  it 'raises an error left on the image by an earlier call', if: Gem::Version.new(Magick::IMAGEMAGICK_VERSION) < Gem::Version.new('7.0.0') do
    image = described_class.new(20, 20)
    resources = %i[area memory map disk]
    limits = resources.to_h { |resource| [resource, Magick.limit_resource(resource, 0)] }
    image.class_type = Magick::PseudoClass

    expect { image.shave!(10, 10) }.to raise_error(Magick::ImageMagickError)
  ensure
    limits&.each { |resource, limit| Magick.limit_resource(resource, limit) }
  end
end
