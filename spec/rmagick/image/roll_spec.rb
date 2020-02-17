RSpec.describe Magick::Image, '#roll' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.roll(5, 5)
    expect(res).to be_instance_of(described_class)
  end
end
