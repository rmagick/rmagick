RSpec.describe Magick::Image, '#_dump' do
  it 'works' do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    expect(image._dump(10)).to be_instance_of(String)
  end
end
