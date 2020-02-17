RSpec.describe Magick::Image, "#channel" do
  it "works" do
    image = described_class.new(20, 20)

    Magick::ChannelType.values do |channel|
      expect { image.channel(channel) }.not_to raise_error
    end

    expect(image.channel(Magick::RedChannel)).to be_instance_of(described_class)
    expect { image.channel(2) }.to raise_error(TypeError)
  end
end
