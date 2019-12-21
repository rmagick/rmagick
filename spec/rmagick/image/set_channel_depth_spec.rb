RSpec.describe Magick::Image, '#set_channel_depth' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    Magick::ChannelType.values do |ch|
      expect { @img.set_channel_depth(ch, 8) }.not_to raise_error
    end
  end
end
