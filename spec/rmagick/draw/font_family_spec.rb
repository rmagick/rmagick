RSpec.describe Magick::Draw, '#font_family' do
  before do
    @draw = described_class.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    draw = described_class.new
    draw.font_family('sans-serif')
    expect(draw.inspect).to eq("font-family 'sans-serif'")
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(@img) }.not_to raise_error
  end
end
