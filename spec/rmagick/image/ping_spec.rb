RSpec.describe Magick::Image, '#ping' do

  it 'returns an image from the source, omitting pixel data' do
    res = Magick::Image.ping(IMAGES_DIR+'/Button_0.gif')
    expect(res).to be_instance_of(Array)
    image = res.first
    expect(image).to be_instance_of(Magick::Image)
    expect(image.format).to eq 'GIF'
    expect(image.columns).to eq 127
    expect(image.rows).to eq 120
    expect(image.filename).to match(/Button_0.gif/)
  end

end
