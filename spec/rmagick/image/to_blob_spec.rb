RSpec.describe Magick::Image, '#to_blob' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    res = nil
    expect { res = @img.to_blob { self.format = 'miff' } }.not_to raise_error
    expect(res).to be_instance_of(String)
    restored = described_class.from_blob(res)
    expect(restored[0]).to eq(@img)
  end
end
