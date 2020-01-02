RSpec.describe Magick::Image, '#scene' do
  before do
    @img = Magick::Image.new(100, 100)
    gc = Magick::Draw.new

    gc.stroke_width(5)
    gc.circle(50, 50, 80, 80)
    gc.draw(@img)

    @hat = Magick::Image.read(FLOWER_HAT).first
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    ilist = Magick::ImageList.new
    ilist << @img
    img = @img.copy
    ilist << img
    ilist.write('temp.gif')
    FileUtils.rm('temp.gif')

    expect { img.scene }.not_to raise_error
    expect(@img.scene).to eq(0)
    expect(img.scene).to eq(1)
    expect { img.scene = 2 }.to raise_error(NoMethodError)
  end
end
