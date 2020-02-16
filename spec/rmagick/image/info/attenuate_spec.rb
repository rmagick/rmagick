RSpec.describe Magick::Image::Info, '#attenuate' do
  it 'works' do
    info = described_class.new

    expect { info.attenuate = 10 }.not_to raise_error
    expect(info.attenuate).to eq(10)
    expect { info.attenuate = 5.25 }.not_to raise_error
    expect(info.attenuate).to eq(5.25)
    expect { info.attenuate = nil }.not_to raise_error
    expect(info.attenuate).to be(nil)
  end
end
