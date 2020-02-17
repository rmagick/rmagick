RSpec.describe Magick::Image, '#shear' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.shear(30, 30)
    expect(res).to be_instance_of(described_class)
  end
end
