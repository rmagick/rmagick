RSpec.describe Magick::Image, '#to_blob' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.to_blob { self.format = 'miff' }
    expect(res).to be_instance_of(String)
    restored = described_class.from_blob(res)
    expect(restored[0]).to eq(img)
  end
end
