RSpec.describe Magick::Image, '#separate' do
  it 'works' do
    image = described_class.new(20, 20)

    expect(image.separate).to be_instance_of(Magick::ImageList)
    expect(image.separate(Magick::BlueChannel)).to be_instance_of(Magick::ImageList)
    expect { image.separate('x') }.to raise_error(TypeError)
  end
end
