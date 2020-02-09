RSpec.describe Magick::Image, '#texture_floodfill' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    texture = described_class.read('granite:').first
    expect do
      res = @img.texture_floodfill(@img.columns / 2, @img.rows / 2, texture)
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error
    expect { @img.texture_floodfill(@img.columns / 2, @img.rows / 2, 'x') }.to raise_error(NoMethodError)
    texture.destroy!
    expect { @img.texture_floodfill(@img.columns / 2, @img.rows / 2, texture) }.to raise_error(Magick::DestroyedImageError)
  end
end
