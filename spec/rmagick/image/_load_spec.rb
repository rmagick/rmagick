RSpec.describe Magick::Image, '#_load' do
  it 'works' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    result = image._dump(10)

    expect(described_class._load(result)).to be_instance_of(described_class)
  end
end
