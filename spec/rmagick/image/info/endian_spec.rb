RSpec.describe Magick::Image::Info, '#endian' do
  it 'works' do
    info = described_class.new

    expect { info.endian = Magick::LSBEndian }.not_to raise_error
    expect(info.endian).to eq(Magick::LSBEndian)
    expect { info.endian = nil }.not_to raise_error
  end
end
