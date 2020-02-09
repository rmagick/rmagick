RSpec.describe Magick::Draw, '#font' do
  before do
    @draw = described_class.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    draw = described_class.new
    font_name = Magick.fonts.first.name
    draw.font(font_name)
    expect(draw.inspect).to eq("font '#{font_name}'")
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(@img) }.not_to raise_error
  end
end
