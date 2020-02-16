RSpec.describe Magick::Image, '#matte_reset!' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.matte_reset!
      expect(res).to be(img)
    end.not_to raise_error
  end
end
