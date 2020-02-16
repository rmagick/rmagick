RSpec.describe Magick::Image, '#sharpen_channel' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.sharpen_channel
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error
    expect { img.sharpen_channel(2.0) }.not_to raise_error
    expect { img.sharpen_channel(2.0, 1.0) }.not_to raise_error
    expect { img.sharpen_channel(2.0, 1.0, Magick::RedChannel) }.not_to raise_error
    expect { img.sharpen_channel(2.0, 1.0, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { img.sharpen_channel(2.0, 1.0, Magick::RedChannel, 2) }.to raise_error(TypeError)
    expect { img.sharpen_channel('x') }.to raise_error(TypeError)
    expect { img.sharpen_channel(2.0, 'x') }.to raise_error(TypeError)
  end
end
