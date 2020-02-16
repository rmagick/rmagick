RSpec.describe Magick::Draw, '#font_family' do
  it 'works' do
    draw = described_class.new
    img = Magick::Image.new(200, 200)

    draw.font_family('sans-serif')
    expect(draw.inspect).to eq("font-family 'sans-serif'")
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(img) }.not_to raise_error
  end
end
