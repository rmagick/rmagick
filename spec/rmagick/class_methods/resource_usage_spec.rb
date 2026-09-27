# frozen_string_literal: true

RSpec.describe Magick, '.resource_usage' do
  def pixel_cache_size
    %i[memory map disk].sum { |resource| described_class.resource_usage(resource) }
  end

  it 'returns the amount of each resource in use' do
    %i[area memory map disk file time].each do |resource|
      expect(described_class.resource_usage(resource)).to be_kind_of(Integer)
      expect(described_class.resource_usage(resource.to_s.upcase)).to be_kind_of(Integer)
    end
  end

  it 'counts the pixel cache of an image until it is destroyed' do
    GC.start
    before = pixel_cache_size

    image = Magick::Image.new(1000, 1000)
    expect(pixel_cache_size - before).to be >= image.columns * image.rows

    image.destroy!
    expect(pixel_cache_size).to be <= before
  end

  it 'raises an error for an unknown resource' do
    expect { described_class.resource_usage(:xxx) }.to raise_error(ArgumentError)
    expect { described_class.resource_usage('xxx') }.to raise_error(ArgumentError)
    expect { described_class.resource_usage('') }.to raise_error(ArgumentError)
    expect { described_class.resource_usage(nil) }.to raise_error(ArgumentError)
    expect { described_class.resource_usage }.to raise_error(ArgumentError)
    expect { described_class.resource_usage(:memory, 1) }.to raise_error(ArgumentError)
  end
end
