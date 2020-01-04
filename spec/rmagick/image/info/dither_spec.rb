RSpec.describe Magick::Image::Info, '#dither' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    expect { @info.dither = true }.not_to raise_error
    expect(@info.dither).to eq(true)
    expect { @info.dither = false }.not_to raise_error
    expect(@info.dither).to eq(false)
  end
end
