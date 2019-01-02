RSpec.describe Magick::ImageList, '#delay_pre' do

  let(:imgList) { Magick::ImageList.new(IMAGES_DIR+'/Hot_Air_Balloons.jpg', IMAGES_DIR+'/Hot_Air_Balloons_H.jpg') }

  it 'returns a gif image' do
    res = imgList.delay_pre
    expect(res).to be_instance_of(Magick::Image)
    expect(res).not_to eq img1
    expect(res.format).to eq 'GIF'
  end

  it 'raises an error when delay_pre value is negative' do
    expect { imgList.delay_pre(0) }.not_to raise_error
    expect { imgList.delay_pre(-1) }.to raise_error(ArgumentError);
    expect { imgList.delay_pre(1, 2) }.to raise_error(ArgumentError);
  end
end
