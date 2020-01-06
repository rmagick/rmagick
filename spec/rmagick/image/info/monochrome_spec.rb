RSpec.describe Magick::Image::Info, '#monochrome' do
  it 'works' do
    info = described_class.new

    expect { info.monochrome = true }.not_to raise_error
    expect(info.monochrome).to be(true)
    expect { info.monochrome = nil }.not_to raise_error
  end
end
