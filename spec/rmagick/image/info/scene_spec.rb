RSpec.describe Magick::Image::Info, '#scene' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    expect { @info.scene = 123 }.not_to raise_error
    expect(@info.scene).to eq(123)
    expect { @info.scene = 'xxx' }.to raise_error(TypeError)
  end
end
