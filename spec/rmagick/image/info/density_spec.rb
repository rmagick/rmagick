RSpec.describe Magick::Image::Info, '#density' do
  it 'works' do
    info = described_class.new

    expect { info.density = '72x72' }.not_to raise_error
    expect(info.density).to eq('72x72')
    expect { info.density = Magick::Geometry.new(72, 72) }.not_to raise_error
    expect(info.density).to eq('72x72')
    expect { info.density = nil }.not_to raise_error
    expect(info.density).to be(nil)
    expect { info.density = 'aaa' }.to raise_error(ArgumentError)
  end
end
