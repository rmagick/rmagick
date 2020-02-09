RSpec.describe Magick::Image, '#from_blob' do
  let(:img) { described_class.read(IMAGES_DIR + '/Button_0.gif').first }
  let(:blob) { img.to_blob }

  it 'returns an image equal to the original' do
    expect(blob).to be_instance_of(String)
    res = described_class.from_blob(blob)
    expect(res).to be_instance_of(Array)
    expect(res.first).to be_instance_of(described_class)
    expect(res.first).to eq img
  end
end
