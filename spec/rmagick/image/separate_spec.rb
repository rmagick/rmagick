RSpec.describe Magick::Image, '#separate' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect(@img.separate).to be_instance_of(Magick::ImageList)
    expect(@img.separate(Magick::BlueChannel)).to be_instance_of(Magick::ImageList)
    expect { @img.separate('x') }.to raise_error(TypeError)
  end
end
