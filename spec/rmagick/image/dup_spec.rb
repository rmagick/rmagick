RSpec.describe Magick::Image, '#dup' do
  it 'works' do
    img = described_class.new(20, 20)

    ditto = img.dup
    expect(ditto).to eq(img)
  end
end
