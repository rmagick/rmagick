RSpec.describe Magick::Image, '#color_profile' do
  it 'works' do
    img = described_class.new(100, 100)
    profile = described_class.read(IMAGE_WITH_PROFILE).first.color_profile

    expect { img.color_profile }.not_to raise_error
    expect(img.color_profile).to be(nil)
    expect { img.color_profile = profile }.not_to raise_error
    expect(img.color_profile).to eq(profile)
    expect { img.color_profile = 2 }.to raise_error(TypeError)
  end
end
