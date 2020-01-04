RSpec.describe Magick::Image::Info, '#endian' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    expect { @info.endian = Magick::LSBEndian }.not_to raise_error
    expect(@info.endian).to eq(Magick::LSBEndian)
    expect { @info.endian = nil }.not_to raise_error
  end
end
