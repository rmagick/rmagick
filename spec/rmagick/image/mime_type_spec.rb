RSpec.describe Magick::Image, '#mime_type' do
  before do
    @img = described_class.new(100, 100)
    gc = Magick::Draw.new

    gc.stroke_width(5)
    gc.circle(50, 50, 80, 80)
    gc.draw(@img)

    @hat = described_class.read(FLOWER_HAT).first
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    img = @img.copy
    img.format = 'GIF'
    expect { img.mime_type }.not_to raise_error
    expect(img.mime_type).to eq('image/gif')
    img.format = 'JPG'
    expect(img.mime_type).to eq('image/jpeg')
    expect { img.mime_type = 'image/jpeg' }.to raise_error(NoMethodError)
  end
end
