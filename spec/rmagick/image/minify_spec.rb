RSpec.describe Magick::Image, '#minify' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.minify
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    res = image.minify!
    expect(res).to be(image)
  end
end
