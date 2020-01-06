RSpec.describe Magick::Draw, '#encoding' do
  it 'works' do
    draw = described_class.new
    img = Magick::Image.new(200, 200)

    draw.encoding('UTF-8')
    expect(draw.inspect).to eq('encoding UTF-8')
    expect { draw.draw(img) }.not_to raise_error
  end
end
