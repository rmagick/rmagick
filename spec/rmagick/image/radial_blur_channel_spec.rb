RSpec.describe Magick::Image, '#radial_blur_channel' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    res = nil
    expect { res = @img.radial_blur_channel(30) }.not_to raise_error
    expect(res).not_to be(nil)
    expect(res).to be_instance_of(described_class)
    expect { res = @img.radial_blur_channel(30, Magick::RedChannel) }.not_to raise_error
    expect { res = @img.radial_blur_channel(30, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error

    expect { @img.radial_blur_channel }.to raise_error(ArgumentError)
    expect { @img.radial_blur_channel(30, 2) }.to raise_error(TypeError)
  end
end
