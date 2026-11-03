# frozen_string_literal: true

RSpec.describe Magick::ImageList, '#marshal_load' do
  def miff_image
    Magick::Image.new(3, 2).tap { |image| image.format = 'MIFF' }
  end

  it 'leaves the dumped array as it is' do
    image_list = described_class.new
    image_list << miff_image << miff_image
    dumped = image_list.marshal_dump
    copy = dumped.map(&:dup)

    described_class.new.marshal_load(dumped)

    expect(dumped).to eq(copy)
  end

  it 'loads a list with Marshal.load and freeze: true' do
    image_list = described_class.new
    image_list << miff_image << miff_image

    loaded = Marshal.load(Marshal.dump(image_list), freeze: true)

    expect(loaded.length).to eq(2)
    expect(loaded.scene).to eq(1)
  end

  it 'loads a frozen list with Marshal.load and freeze: true', if: Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.3') do
    image_list = described_class.new
    image_list << miff_image << miff_image

    loaded = Marshal.load(Marshal.dump(image_list), freeze: true)

    expect(loaded).to be_frozen
  end
end
