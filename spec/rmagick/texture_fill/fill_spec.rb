RSpec.describe Magick::TextureFill, '#fill' do
  it 'works' do
    granite = Magick::Image.read('granite:').first
    texture = described_class.new(granite)

    image = Magick::Image.new(10, 10)
    obj = texture.fill(image)
    expect(obj).to eq(texture)
  end

  it 'accepts an ImageList argument' do
    granite = Magick::Image.read('granite:').first
    texture = described_class.new(granite)

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)

    obj = texture.fill(image_list)
    expect(obj).to eq(texture)
  end
end
