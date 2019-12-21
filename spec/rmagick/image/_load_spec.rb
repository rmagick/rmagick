RSpec.describe Magick::Image, '#_load' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    res = img._dump(10)

    expect(Magick::Image._load(res)).to be_instance_of(Magick::Image)
  end
end
