RSpec.describe Magick::Image, '#normalize_channel' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.normalize_channel
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.normalize_channel(Magick::RedChannel) }.not_to raise_error
    expect { @img.normalize_channel(Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.normalize_channel(Magick::RedChannel, 2) }.to raise_error(TypeError)
  end
end
