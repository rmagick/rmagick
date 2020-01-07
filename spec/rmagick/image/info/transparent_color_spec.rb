RSpec.describe Magick::Image::Info, '#transparent_color' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    expect { @info.transparent_color = 'white' }.not_to raise_error
    expect(@info.transparent_color).to eq('white')
    expect { @info.transparent_color = nil }.to raise_error(TypeError)
  end
end
