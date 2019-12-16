RSpec.describe Magick::Image, '#_dump' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    expect(img._dump(10)).to be_instance_of(String)
  end
end
