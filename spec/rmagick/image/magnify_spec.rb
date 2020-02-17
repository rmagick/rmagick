RSpec.describe Magick::Image, '#magnify' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.magnify
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(img)

    res = img.magnify!
    expect(res).to be(img)
  end
end
