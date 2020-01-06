RSpec.describe Magick::Image, '#separate' do
  it 'works' do
    img = described_class.new(20, 20)

    expect(img.separate).to be_instance_of(Magick::ImageList)
    expect(img.separate(Magick::BlueChannel)).to be_instance_of(Magick::ImageList)
    expect { img.separate('x') }.to raise_error(TypeError)
  end
end
