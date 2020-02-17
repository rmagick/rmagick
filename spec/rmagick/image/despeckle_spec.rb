RSpec.describe Magick::Image, '#despeckle' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.despeckle
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(img)
  end
end
