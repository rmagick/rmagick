# frozen_string_literal: true

RSpec.describe Magick::Image, '#get_exif_by_number' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.get_exif_by_number
    expect(result).to be_instance_of(Hash)
  end

  it "returns the values of the tags of a frozen image" do
    image = described_class.read(IMAGE_WITH_PROFILE).first
    expected = { 0x112 => "1", 0xa001 => "65535", 0x9999 => nil }

    expect(image.get_exif_by_number(0x112, 0xa001, 0x9999)).to eq(expected)
    frozen = described_class.read(IMAGE_WITH_PROFILE).first.freeze
    expect(frozen.get_exif_by_number(0x112, 0xa001, 0x9999)).to eq(expected)
  end
end
