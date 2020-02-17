RSpec.describe Magick::Image, '#copy' do
  it 'works' do
    image = described_class.new(20, 20)

    ditto = image.copy
    expect(ditto).to eq(image)
  end
end
