RSpec.describe Magick::Image, '#channel_entropy' do
  it 'returns a channel entropy', unsupported_before('6.9.0') do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first

    result = image.channel_entropy
    expect(result).to eq([0.5285857222715863])
  end
end
