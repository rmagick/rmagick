RSpec.describe Magick::Image, '#bnw' do

  let(:img) { Magick::Image(IMAGES_DIR+'/Hot_Air_Balloons.jpg').first }

  it 'returns an image' do
    res = img.bnw
    expect(res).to be_instance_of(Magick::Image)
    expect(res).not_to eq img
  end
end
