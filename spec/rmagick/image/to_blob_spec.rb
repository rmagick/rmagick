RSpec.describe Magick::Image, '#to_blob' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    res = nil
    expect { res = @img.to_blob { self.format = 'miff' } }.not_to raise_error
    expect(res).to be_instance_of(String)
    restored = Magick::Image.from_blob(res)
    expect(restored[0]).to eq(@img)
  end
end
