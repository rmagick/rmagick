RSpec.describe Magick::Image::Info, '#quality' do
  before do
    @info = described_class.new
  end

  it 'works' do
    expect { @info.quality = 75 }.not_to raise_error
    expect(@info.quality).to eq(75)
  end
end
