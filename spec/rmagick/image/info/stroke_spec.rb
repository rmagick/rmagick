RSpec.describe Magick::Image::Info, '#stroke' do
  it 'works' do
    info = described_class.new

    expect { info.stroke }.not_to raise_error
    expect(info.stroke).to be(nil)

    expect { info.stroke = 'white' }.not_to raise_error
    expect(info.stroke).to eq('white')

    expect { info.stroke = nil }.not_to raise_error
    expect(info.stroke).to be(nil)

    expect { info.stroke = 'xxx' }.to raise_error(ArgumentError)
  end
end
