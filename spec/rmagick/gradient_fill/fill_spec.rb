RSpec.describe Magick::GradientFill, '#fill' do
  it 'works' do
    img = Magick::Image.new(10, 10)

    gradient = described_class.new(0, 0, 0, 0, '#900', '#000')
    obj = gradient.fill(img)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, 0, 0, 10, '#900', '#000')
    obj = gradient.fill(img)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, 0, 10, 0, '#900', '#000')
    obj = gradient.fill(img)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, 0, 10, 10, '#900', '#000')
    obj = gradient.fill(img)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, 0, 5, 20, '#900', '#000')
    obj = gradient.fill(img)
    expect(obj).to eq(gradient)

    gradient = described_class.new(-10, 0, -10, 10, '#900', '#000')
    obj = gradient.fill(img)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, -10, 10, -10, '#900', '#000')
    obj = gradient.fill(img)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, -10, 10, -20, '#900', '#000')
    obj = gradient.fill(img)
    expect(obj).to eq(gradient)

    gradient = described_class.new(0, 100, 100, 200, '#900', '#000')
    obj = gradient.fill(img)
    expect(obj).to eq(gradient)
  end
end
