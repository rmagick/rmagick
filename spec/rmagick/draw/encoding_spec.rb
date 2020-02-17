RSpec.describe Magick::Draw, '#encoding' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.encoding('UTF-8')
    expect(draw.inspect).to eq('encoding UTF-8')
    expect { draw.draw(image) }.not_to raise_error
  end
end
