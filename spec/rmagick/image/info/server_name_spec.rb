RSpec.describe Magick::Image::Info, '#server_name' do
  before do
    @info = described_class.new
  end

  it 'works' do
    expect { @info.server_name = 'foo' }.not_to raise_error
    expect(@info.server_name).to eq('foo')
    expect { @info.server_name = nil }.not_to raise_error
    expect(@info.server_name).to be(nil)
  end
end
