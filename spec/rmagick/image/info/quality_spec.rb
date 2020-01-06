RSpec.describe Magick::Image::Info, '#quality' do
  it 'works' do
    info = described_class.new

    expect { info.quality = 75 }.not_to raise_error
    expect(info.quality).to eq(75)
  end
end
