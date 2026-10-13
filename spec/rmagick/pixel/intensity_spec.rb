# frozen_string_literal: true

RSpec.describe Magick::Pixel, '#intensity' do
  it 'works' do
    pixel = described_class.from_color('brown')

    expect(pixel.intensity).to be_kind_of(Integer)
  end

  it 'rounds a negative value of an HDRI pixel' do
    pixel = described_class.new(-65_535, 0, 0)
    expected = Magick::Magick_features.include?('HDRI') ? -19_595 : 0

    expect(pixel.intensity).to eq(expected)
  end
end
