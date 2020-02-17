RSpec.describe Magick::Image, '#roll' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.roll(5, 5)
    expect(res).to be_instance_of(described_class)
  end
end
