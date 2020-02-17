RSpec.describe Magick::Image, '#color_profile' do
  it 'works' do
    image = described_class.new(100, 100)
    profile = described_class.read(IMAGE_WITH_PROFILE).first.color_profile

    expect { image.color_profile }.not_to raise_error
    expect(image.color_profile).to be(nil)
    expect { image.color_profile = profile }.not_to raise_error
    expect(image.color_profile).to eq(profile)
    expect { image.color_profile = 2 }.to raise_error(TypeError)
  end
end
