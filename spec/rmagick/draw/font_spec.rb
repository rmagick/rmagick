RSpec.describe Magick::Draw, '#font' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    font_name = Magick.fonts.first.name
    draw.font(font_name)
    expect(draw.inspect).to eq("font '#{font_name}'")
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(image) }.not_to raise_error
  end
end
