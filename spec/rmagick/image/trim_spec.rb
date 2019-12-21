RSpec.describe Magick::Image, '#trim' do
  it 'works' do
    # Can't use the default image because it's a solid color
    hat = Magick::Image.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    expect do
      expect(hat.trim).to be_instance_of(Magick::Image)
      expect(hat.trim(10)).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { hat.trim(10, 10) }.to raise_error(ArgumentError)
  end
end
