RSpec.describe Magick::Image, '#normalize_channel' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.normalize_channel
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(img)
    end.not_to raise_error
    expect { img.normalize_channel(Magick::RedChannel) }.not_to raise_error
    expect { img.normalize_channel(Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { img.normalize_channel(Magick::RedChannel, 2) }.to raise_error(TypeError)
  end
end
