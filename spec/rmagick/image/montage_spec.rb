RSpec.describe Magick::Image, '#montage' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.montage }.not_to raise_error
    expect(image.montage).to be(nil)
  end
end
