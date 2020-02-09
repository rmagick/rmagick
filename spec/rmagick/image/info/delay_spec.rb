RSpec.describe Magick::Image::Info, '#delay' do
  before do
    @info = described_class.new
  end

  it 'works' do
    expect { @info.delay = 60 }.not_to raise_error
    expect(@info.delay).to eq(60)
    expect { @info.delay = nil }.not_to raise_error
    expect(@info.delay).to be(nil)
    expect { @info.delay = '60' }.to raise_error(TypeError)
  end
end
