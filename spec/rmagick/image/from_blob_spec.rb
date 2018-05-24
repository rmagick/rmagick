RSpec.describe Magick::Image, '#from_blob' do
  let(:img) { Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first }
  let(:blob) { img.to_blob }

  it 'returns an image equal to the original' do
    expect(blob).to be_instance_of(String)
    res = Magick::Image.from_blob(blob)
    expect(res).to be_instance_of(Array)
    expect(res.first).to be_instance_of(Magick::Image)
    expect(res.first).to eq img
  end
end
