RSpec.describe Magick::Image::Info, '#undercolor' do
  it 'works' do
    info = described_class.new

    expect { info.undercolor }.not_to raise_error
    expect(info.undercolor).to be(nil)

    expect { info.undercolor = 'white' }.not_to raise_error
    expect(info.undercolor).to eq('white')

    expect { info.undercolor = nil }.not_to raise_error
    expect(info.undercolor).to be(nil)

    expect { info.undercolor = 'xxx' }.to raise_error(ArgumentError)
  end
end
