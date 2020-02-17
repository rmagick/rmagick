RSpec.describe Magick::Image, '#channel_entropy' do
  it 'returns a channel entropy', supported_after('6.9.0') do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first

    res = image.channel_entropy
    expect(res).to eq([0.5285857222715863])
  end
end
