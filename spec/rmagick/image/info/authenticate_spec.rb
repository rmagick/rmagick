RSpec.describe Magick::Image::Info, '#authenticate' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    expect { @info.authenticate = 'string' }.not_to raise_error
    expect(@info.authenticate).to eq('string')
    expect { @info.authenticate = nil }.not_to raise_error
    expect(@info.authenticate).to be(nil)
    expect { @info.authenticate = '' }.not_to raise_error
    expect(@info.authenticate).to eq('')
  end
end
