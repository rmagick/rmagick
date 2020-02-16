RSpec.describe Magick::Image::Info, '#channel' do
  it 'works' do
    info = described_class.new

    expect { info.channel(Magick::RedChannel) }.not_to raise_error
    expect { info.channel(Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { info.channel(1) }.to raise_error(TypeError)
    expect { info.channel(Magick::RedChannel, 1) }.to raise_error(TypeError)
  end
end
