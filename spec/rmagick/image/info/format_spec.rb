RSpec.describe Magick::Image::Info, '#format' do
  before do
    @info = described_class.new
  end

  it 'works' do
    expect { @info.format = 'GIF' }.not_to raise_error
    expect(@info.format).to eq('GIF')
    expect { @info.format = nil }.to raise_error(TypeError)
  end
end
