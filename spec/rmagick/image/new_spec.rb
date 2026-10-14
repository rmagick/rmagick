# frozen_string_literal: true

RSpec.describe Magick::Image, '#new' do
  it 'works Call yield when there is a block argument (issue 699)' do
    self_obj = nil
    yield_obj = nil

    described_class.new(20, 20) do |options|
      yield_obj = options
      self_obj = self
    end

    expect(yield_obj).to be_instance_of(Magick::Image::Info)
    expect(self_obj).to eq(self)
  end

  it 'sync Image::Info' do
    image = described_class.new(20, 20) do |options|
      options.colorspace = Magick::LabColorspace
    end
    expect(image.colorspace).to eq(Magick::LabColorspace)
  end

  it 'returns an image with no columns on ImageMagick 6', if: Gem::Version.new(Magick::IMAGEMAGICK_VERSION) < Gem::Version.new('7.0.0') do
    image = described_class.new(0, 5)

    expect(image.columns).to eq(0)
  end

  it 'raises an error when ImageMagick runs out of resources' do
    resources = %i[area memory map disk]
    limits = resources.to_h { |resource| [resource, Magick.limit_resource(resource, 0)] }

    expect { described_class.new(20, 20) }.to raise_error(Magick::ImageMagickError)
  ensure
    limits&.each { |resource, limit| Magick.limit_resource(resource, limit) }
  end

  it 'releases the image it held when it is called again' do
    image = described_class.new(1000, 1000)
    GC.start
    baseline = Magick.resource_usage(:memory)

    image.__send__(:initialize, 1000, 1000)

    expect(Magick.resource_usage(:memory)).to be <= baseline
  end

  it 'raises FrozenError when it is called again on a frozen image' do
    image = described_class.new(2, 2).freeze

    expect { image.__send__(:initialize, 5, 5) }.to raise_error(FrozenError)
    expect(image.columns).to eq(2)
  end
end
