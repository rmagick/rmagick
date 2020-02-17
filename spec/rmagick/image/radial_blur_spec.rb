RSpec.describe Magick::Image, '#radial_blur' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.radial_blur(30)
    expect(res).to be_instance_of(described_class)
  end
end
