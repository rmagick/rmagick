RSpec.describe Magick::Pixel, '#hash' do
  it 'works' do
    pixel = described_class.from_color('brown')

    hash = nil
    expect { hash = pixel.hash }.not_to raise_error
    expect(hash).not_to be(nil)
    expect(hash).to eq(1_385_502_079)

    pixel = described_class.new
    expect(pixel.hash).to eq(127)

    pixel = described_class.from_color('red')
    expect(pixel.hash).to eq(2_139_095_167)

    # Pixel.hash sacrifices the last bit of the opacity channel
    pixel = described_class.new(0, 0, 0, 72)
    pixel2 = described_class.new(0, 0, 0, 73)
    expect(pixel2).not_to eq(pixel)
    expect(pixel2.hash).to eq(pixel.hash)
  end
end
