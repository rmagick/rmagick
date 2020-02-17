RSpec.describe Magick::Image, '#bounding_box' do
  it 'works' do
    image = described_class.new(100, 100)
    gc = Magick::Draw.new

    gc.stroke_width(5)
    gc.circle(50, 50, 80, 80)
    gc.draw(image)

    expect { image.bounding_box }.not_to raise_error
    box = image.bounding_box
    expect(box.width).to eq(87)
    expect(box.height).to eq(87)
    expect(box.x).to eq(7)
    expect(box.y).to eq(7)
    expect { image.bounding_box = 2 }.to raise_error(NoMethodError)
  end
end
