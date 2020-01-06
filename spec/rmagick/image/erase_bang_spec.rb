RSpec.describe Magick::Image, '#erase!' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.erase!
      expect(res).to be(img)
    end.not_to raise_error
  end
end
