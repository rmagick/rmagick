RSpec.describe Magick::Image, '#radial_blur' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.radial_blur(30)
    expect(result).to be_instance_of(described_class)
  end
end
