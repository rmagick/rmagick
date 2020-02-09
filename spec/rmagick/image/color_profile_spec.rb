RSpec.describe Magick::Image, '#color_profile' do
  before do
    @img = described_class.new(100, 100)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect { @img.color_profile }.not_to raise_error
    expect(@img.color_profile).to be(nil)
    expect { @img.color_profile = @p }.not_to raise_error
    expect(@img.color_profile).to eq(@p)
    expect { @img.color_profile = 2 }.to raise_error(TypeError)
  end
end
