RSpec.describe Magick::Image, '#set_channel_depth' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    Magick::ChannelType.values do |ch|
      expect { @img.set_channel_depth(ch, 8) }.not_to raise_error
    end
  end
end
