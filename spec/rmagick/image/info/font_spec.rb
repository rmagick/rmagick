RSpec.describe Magick::Image::Info, '#font' do
  it 'works' do
    info = described_class.new

    expect { info.font = 'Arial' }.not_to raise_error
    expect(info.font).to eq('Arial')
    expect { info.font = nil }.not_to raise_error
    expect(info.font).to be(nil)
  end
end
