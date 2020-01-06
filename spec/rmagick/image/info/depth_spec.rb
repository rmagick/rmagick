RSpec.describe Magick::Image::Info, '#depth' do
  it 'works' do
    info = described_class.new

    expect { info.depth = 8 }.not_to raise_error
    expect(info.depth).to eq(8)
    expect { info.depth = 16 }.not_to raise_error
    expect(info.depth).to eq(16)
    expect { info.depth = 32 }.to raise_error(ArgumentError)
  end
end
