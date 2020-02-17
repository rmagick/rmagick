RSpec.describe Magick::Image, '#copy' do
  it 'works' do
    img = described_class.new(20, 20)

    ditto = img.copy
    expect(ditto).to eq(img)
  end
end
