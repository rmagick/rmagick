RSpec.describe Magick::Image, '#constitute' do
  let(:img) { Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first }
  let(:pixels) { img.dispatch(0, 0, img.columns, img.rows, 'RGBA') }

  it 'returns an equivalent image to the given pixels' do
    res = Magick::Image.constitute(img.columns, img.rows, 'RGBA', pixels)
    # The constituted image is in MIFF format so we
    # can't compare it directly to the original image.
    expect(res.columns).to eq img.columns
    expect(res.rows).to eq img.rows
    expect(pixels.all? { |v| v >= 0 && v <= Magick::QuantumRange }).to be true
  end
end
