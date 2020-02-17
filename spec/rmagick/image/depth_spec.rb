RSpec.describe Magick::Image, '#depth' do
  it 'works' do
    image = described_class.new(100, 100)
    gc = Magick::Draw.new

    gc.stroke_width(5)
    gc.circle(50, 50, 80, 80)
    gc.draw(image)

    expect(image.depth).to eq(Magick::MAGICKCORE_QUANTUM_DEPTH)
    expect { image.depth = 2 }.to raise_error(NoMethodError)
  end
end
