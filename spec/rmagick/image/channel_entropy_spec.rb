RSpec.describe Magick::Image, '#channel_entropy' do
  let(:img) { described_class.read(IMAGES_DIR + '/Button_0.gif').first }

  it 'returns a channel entropy', supported_after('6.9.0') do
    res = img.channel_entropy
    expect(res).to eq([0.5285857222715863])
  end
end
