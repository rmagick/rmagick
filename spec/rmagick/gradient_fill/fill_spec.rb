RSpec.describe Magick::GradientFill, '#fill' do
  it 'works' do
    image = Magick::Image.new(10, 10)

    gradient = described_class.new(0, 0, 0, 0, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, 0, 0, 10, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, 0, 10, 0, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, 0, 10, 10, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, 0, 5, 20, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)

    gradient = described_class.new(-10, 0, -10, 10, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, -10, 10, -10, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, -10, 10, -20, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, 100, 100, 200, '#900', '#000')
    obj = gradient.fill(image)
    expect(obj).to eq(gradient)
  end

  it 'accepts an ImageList argument' do
    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)

    gradient = described_class.new(0, 0, 0, 0, '#900', '#000')
    obj = gradient.fill(image_list)
    expect(obj).to eq(gradient)
  end
end
