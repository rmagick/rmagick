RSpec.describe Magick::Image, '#equalize_channel' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.equalize_channel
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.equalize_channel }.not_to raise_error
    expect { @img.equalize_channel(Magick::RedChannel) }.not_to raise_error
    expect { @img.equalize_channel(Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.equalize_channel(Magick::RedChannel, 2) }.to raise_error(TypeError)
  end
end
