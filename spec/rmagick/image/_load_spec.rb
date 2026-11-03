# frozen_string_literal: true

RSpec.describe Magick::Image, '#_load' do
  it 'works' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    result = image._dump(10)

    expect(described_class._load(result)).to be_instance_of(described_class)
  end

  it 'keeps only the first image of a dump that reads back as several images' do
    image = described_class.new(100, 100)
    image.format = 'PSD'
    dumped = image._dump(0)
    GC.start
    before = pixel_cache_size

    loaded = described_class._load(dumped)
    loaded.destroy!

    expect(pixel_cache_size).to eq(before)
  end
end
