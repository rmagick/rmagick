RSpec.describe Magick::TextureFill, '#fill' do
  it 'works' do
    granite = Magick::Image.read('granite:').first
    texture = described_class.new(granite)

    image = Magick::Image.new(10, 10)
    obj = texture.fill(image)
    expect(obj).to eq(texture)

    imgl = Magick::ImageList.new
    imgl.new_image(10, 10)

    obj = texture.fill(imgl)
    expect(obj).to eq(texture)
  end
end
