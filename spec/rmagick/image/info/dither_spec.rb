RSpec.describe Magick::Image::Info, '#dither' do
  it 'works' do
    info = described_class.new

    expect { info.dither = true }.not_to raise_error
    expect(info.dither).to eq(true)
    expect { info.dither = false }.not_to raise_error
    expect(info.dither).to eq(false)
  end
end
