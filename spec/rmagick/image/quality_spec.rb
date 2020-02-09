RSpec.describe Magick::Image, '#quality' do
  before do
    @hat = described_class.read(FLOWER_HAT).first
  end

  it 'works' do
    expect { @hat.quality }.not_to raise_error
    expect(@hat.quality).to eq(75)
    expect { @hat.quality = 80 }.to raise_error(NoMethodError)
  end
end
