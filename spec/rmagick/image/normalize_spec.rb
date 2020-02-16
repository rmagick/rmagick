RSpec.describe Magick::Image, '#normalize' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.normalize
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(img)
    end.not_to raise_error
  end
end
