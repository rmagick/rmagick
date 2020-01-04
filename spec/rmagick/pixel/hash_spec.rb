RSpec.describe Magick::Pixel, '#hash' do
  before do
    @pixel = Magick::Pixel.from_color('brown')
  end

  it 'works' do
    hash = nil
    expect { hash = @pixel.hash }.not_to raise_error
    expect(hash).not_to be(nil)
    expect(hash).to eq(1_385_502_079)

    p = Magick::Pixel.new
    expect(p.hash).to eq(127)

    p = Magick::Pixel.from_color('red')
    expect(p.hash).to eq(2_139_095_167)

    # Pixel.hash sacrifices the last bit of the opacity channel
    p = Magick::Pixel.new(0, 0, 0, 72)
    p2 = Magick::Pixel.new(0, 0, 0, 73)
    expect(p2).not_to eq(p)
    expect(p2.hash).to eq(p.hash)
  end
end
