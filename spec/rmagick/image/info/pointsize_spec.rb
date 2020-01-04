RSpec.describe Magick::Image::Info, '#pointsize' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    expect { @info.pointsize = 12 }.not_to raise_error
    expect(@info.pointsize).to eq(12)
  end
end
