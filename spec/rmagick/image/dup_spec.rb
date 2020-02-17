RSpec.describe Magick::Image, '#dup' do
  it 'works' do
    image = described_class.new(20, 20)

    ditto = image.dup
    expect(ditto).to eq(image)
  end
end
