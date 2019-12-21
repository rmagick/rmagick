RSpec.describe Magick::Image, '#reduce_noise' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect do
      res = @img.reduce_noise(0)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.reduce_noise(4) }.not_to raise_error
  end
end
