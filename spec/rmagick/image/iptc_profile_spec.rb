RSpec.describe Magick::Image, '#iptc_profile' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.iptc_profile }.not_to raise_error
    expect(image.iptc_profile).to be(nil)
    expect { image.iptc_profile = 'xxx' }.not_to raise_error
    expect(image.iptc_profile).to eq('xxx')
    expect { image.iptc_profile = 2 }.to raise_error(TypeError)
  end
end
