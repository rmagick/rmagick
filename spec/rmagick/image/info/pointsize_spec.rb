RSpec.describe Magick::Image::Info, '#pointsize' do
  it 'works' do
    info = described_class.new

    expect { info.pointsize = 12 }.not_to raise_error
    expect(info.pointsize).to eq(12)
  end
end
