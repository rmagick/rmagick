RSpec.describe Magick::Image, '#selective_blur_channel' do
  it 'works' do
    img = described_class.new(20, 20)
    res = nil

    expect { res = img.selective_blur_channel(0, 1, '10%') }.not_to raise_error
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(img)
    expect([res.columns, res.rows]).to eq([img.columns, img.rows])

    expect { img.selective_blur_channel(0, 1, 0.1) }.not_to raise_error
    expect { img.selective_blur_channel(0, 1, '10%', Magick::RedChannel) }.not_to raise_error
    expect { img.selective_blur_channel(0, 1, '10%', Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { img.selective_blur_channel(0, 1, '10%', Magick::RedChannel, Magick::BlueChannel, Magick::GreenChannel) }.not_to raise_error

    expect { img.selective_blur_channel(0, 1) }.to raise_error(ArgumentError)
    expect { img.selective_blur_channel(0, 1, 0.1, '10%') }.to raise_error(TypeError)
  end
end
