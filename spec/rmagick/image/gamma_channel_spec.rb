RSpec.describe Magick::Image, '#gamma_channel' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.gamma_channel(0.8)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.gamma_channel }.to raise_error(ArgumentError)
    expect { @img.gamma_channel(0.8, Magick::RedChannel) }.not_to raise_error
    expect { @img.gamma_channel(0.8, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.gamma_channel(0.8, Magick::RedChannel, 2) }.to raise_error(TypeError)
  end
end
