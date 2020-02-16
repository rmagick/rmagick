RSpec.describe Magick::Image::Info, '#server_name' do
  it 'works' do
    info = described_class.new

    expect { info.server_name = 'foo' }.not_to raise_error
    expect(info.server_name).to eq('foo')
    expect { info.server_name = nil }.not_to raise_error
    expect(info.server_name).to be(nil)
  end
end
