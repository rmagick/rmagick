RSpec.describe Magick::TextureFill, '#initialize' do
  it 'works' do
    granite = Magick::Image.read('granite:').first
    expect(described_class.new(granite)).to be_instance_of(described_class)
  end

  it 'accepts an ImageList argument' do
    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    expect(described_class.new(image_list)).to be_instance_of(described_class)
  end

  it 'raises an exception if an unexpected argument was given' do
    expect { described_class.new([1]) }.to raise_error(NoMethodError)
  end
end
