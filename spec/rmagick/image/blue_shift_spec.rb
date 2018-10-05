RSpec.describe Magick::Image, '#blue_shift' do
  let(:img) { Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first }

  it 'returns a new Image' do
    res = img.blue_shift
    expect(res).to be_instance_of(Magick::Image)
    expect(res).not_to eq img
  end

  it 'accepts one argument' do
    expect { img.blue_shift(2) }.not_to raise_error
    expect { img.blue_shift(2, 3) }.to raise_error(ArgumentError)
  end
end
