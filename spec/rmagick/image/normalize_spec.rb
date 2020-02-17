RSpec.describe Magick::Image, '#normalize' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.normalize
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(img)
  end
end
