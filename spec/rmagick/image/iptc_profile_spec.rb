RSpec.describe Magick::Image, '#iptc_profile' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.iptc_profile }.not_to raise_error
    expect(img.iptc_profile).to be(nil)
    expect { img.iptc_profile = 'xxx' }.not_to raise_error
    expect(img.iptc_profile).to eq('xxx')
    expect { img.iptc_profile = 2 }.to raise_error(TypeError)
  end
end
