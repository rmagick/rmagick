RSpec.describe Magick::Draw, '#text_undercolor' do
  it 'works' do
    draw = described_class.new
    img = Magick::Image.new(200, 200)

    draw.text_undercolor('red')
    expect(draw.inspect).to eq('text-undercolor "red"')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(img) }.not_to raise_error
  end
end
