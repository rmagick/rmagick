RSpec.describe Magick::Image, "#channel" do
  before do
    @img = Magick::Image.new(20, 20)
  end

  it "works" do
    Magick::ChannelType.values do |channel|
      expect { @img.channel(channel) }.not_to raise_error
    end

    expect(@img.channel(Magick::RedChannel)).to be_instance_of(Magick::Image)
    expect { @img.channel(2) }.to raise_error(TypeError)
  end
end
