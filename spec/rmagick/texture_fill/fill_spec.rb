RSpec.describe Magick::TextureFill, '#fill' do
  it 'works' do
    granite = Magick::Image.read('granite:').first
    texture = described_class.new(granite)

    img = Magick::Image.new(10, 10)
    obj = texture.fill(img)
    expect(obj).to eq(texture)
  end
end
