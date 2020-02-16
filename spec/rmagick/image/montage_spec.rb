RSpec.describe Magick::Image, '#montage' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.montage }.not_to raise_error
    expect(img.montage).to be(nil)
  end
end
