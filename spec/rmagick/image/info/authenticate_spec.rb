RSpec.describe Magick::Image::Info, '#authenticate' do
  it 'works' do
    info = described_class.new

    expect { info.authenticate = 'string' }.not_to raise_error
    expect(info.authenticate).to eq('string')
    expect { info.authenticate = nil }.not_to raise_error
    expect(info.authenticate).to be(nil)
    expect { info.authenticate = '' }.not_to raise_error
    expect(info.authenticate).to eq('')
  end
end
