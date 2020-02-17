RSpec.describe Magick::Image, '#shear' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.shear(30, 30)
    expect(result).to be_instance_of(described_class)
  end
end
