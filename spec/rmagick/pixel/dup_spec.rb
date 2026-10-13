# frozen_string_literal: true

RSpec.describe Magick::Pixel, '#dup' do
  it 'works' do
    pixel = described_class.from_color('brown')

    pixel2 = pixel.dup
    expect(pixel === pixel2).to be(true)
    expect(pixel2.object_id).not_to eq(pixel.object_id)

    pixel2 = pixel.freeze.dup
    expect(pixel2.frozen?).to be(false)
  end

  it 'does not copy into a frozen pixel' do
    pixel = described_class.new(1, 2, 3).freeze

    expect { pixel.__send__(:initialize_copy, described_class.new(4, 5, 6)) }.to raise_error(FrozenError)
    expect(pixel.red).to eq(1)
  end
end
