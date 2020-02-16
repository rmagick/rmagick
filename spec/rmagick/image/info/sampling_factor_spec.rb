RSpec.describe Magick::Image::Info, '#sampling_factor' do
  it 'works' do
    info = described_class.new

    expect { info.sampling_factor = '2x1' }.not_to raise_error
    expect(info.sampling_factor).to eq('2x1')
    expect { info.sampling_factor = nil }.not_to raise_error
    expect(info.sampling_factor).to be(nil)
  end
end
