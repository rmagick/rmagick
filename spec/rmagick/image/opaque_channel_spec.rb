RSpec.describe Magick::Image, '#opaque_channel' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.opaque_channel('white', 'red')
    expect(res).not_to be(nil)
    expect(res).to be_instance_of(described_class)
    expect(img).not_to be(res)

    expect { img.opaque_channel('red', 'blue', true) }.not_to raise_error
    expect { img.opaque_channel('red', 'blue', true, 50) }.not_to raise_error
    expect { img.opaque_channel('red', 'blue', true, 50, Magick::RedChannel) }.not_to raise_error
    expect { img.opaque_channel('red', 'blue', true, 50, Magick::RedChannel, Magick::GreenChannel) }.not_to raise_error
    expect do
      img.opaque_channel('red', 'blue', true, 50, Magick::RedChannel, Magick::GreenChannel, Magick::BlueChannel)
    end.not_to raise_error

    expect { img.opaque_channel('red', 'blue', true, 50, 50) }.to raise_error(TypeError)
    expect { img.opaque_channel('red', 'blue', true, []) }.to raise_error(TypeError)
    expect { img.opaque_channel('red') }.to raise_error(ArgumentError)
    expect { img.opaque_channel('red', 'blue', true, -0.1) }.to raise_error(ArgumentError)
    expect { img.opaque_channel('red', []) }.to raise_error(TypeError)
  end
end
