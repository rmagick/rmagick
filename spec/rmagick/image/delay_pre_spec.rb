RSpec.describe Magick::ImageList, '#delay_pre' do

  let(:imgList) { Magick::ImageList.new(IMAGES_DIR+'/Hot_Air_Balloons.jpg', IMAGES_DIR+'/Hot_Air_Balloons_H.jpg') }

  it 'returns a gif image' do
    res = imgList.delay_pre
    expect(res).to be_instance_of(Magick::Image)
    expect(res).not_to eq img1
    expect(res.format).to eq 'GIF'
  end
end
