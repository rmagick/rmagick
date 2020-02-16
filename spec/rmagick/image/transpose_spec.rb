RSpec.describe Magick::Image, '#transpose' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.transpose
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(img)
    end.not_to raise_error
    expect do
      res = img.transpose!
      expect(res).to be_instance_of(described_class)
      expect(res).to be(img)
    end.not_to raise_error
  end
end
