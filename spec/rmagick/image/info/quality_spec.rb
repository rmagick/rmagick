RSpec.describe Magick::Image::Info, '#quality' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    expect { @info.quality = 75 }.not_to raise_error
    expect(@info.quality).to eq(75)
  end
end
