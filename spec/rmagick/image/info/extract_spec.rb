RSpec.describe Magick::Image::Info, '#extract' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    expect { @info.extract = '100x100' }.not_to raise_error
    expect(@info.extract).to eq('100x100')
    expect { @info.extract = Magick::Geometry.new(100, 100) }.not_to raise_error
    expect(@info.extract).to eq('100x100')
    expect { @info.extract = nil }.not_to raise_error
    expect(@info.extract).to be(nil)
    expect { @info.extract = 'aaa' }.to raise_error(ArgumentError)
  end
end
