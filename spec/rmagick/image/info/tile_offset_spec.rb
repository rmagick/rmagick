RSpec.describe Magick::Image::Info, '#tile_offset' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    expect { @info.tile_offset = '200x100' }.not_to raise_error
    expect(@info.tile_offset).to eq('200x100')
    expect { @info.tile_offset = Magick::Geometry.new(100, 200) }.not_to raise_error
    expect(@info.tile_offset).to eq('100x200')
    expect { @info.tile_offset = nil }.to raise_error(ArgumentError)
  end
end
