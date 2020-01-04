RSpec.describe Magick::Image::Info, '#number_scenes' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    expect(@info.number_scenes).to be_kind_of(Integer)
    expect { @info.number_scenes = 50 }.not_to raise_error
    expect(@info.number_scenes).to eq(50)
    expect { @info.number_scenes = nil }.to raise_error(TypeError)
    expect { @info.number_scenes = 'xxx' }.to raise_error(TypeError)
  end
end
