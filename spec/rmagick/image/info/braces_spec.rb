RSpec.describe Magick::Image::Info, '#[]' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    # 1-argument form
    expect { @info['fill'] }.not_to raise_error
    expect(@info['fill']).to be(nil)

    expect { @info['fill'] = 'red' }.not_to raise_error
    expect(@info['fill']).to eq('red')

    expect { @info['fill'] = nil }.not_to raise_error
    expect(@info['fill']).to be(nil)

    # 2-argument form
    expect { @info['tiff', 'bits-per-sample'] = 2 }.not_to raise_error
    expect(@info['tiff', 'bits-per-sample']).to eq('2')

    # define and undefine
    expect { @info.define('tiff', 'bits-per-sample', 4) }.not_to raise_error
    expect(@info['tiff', 'bits-per-sample']).to eq('4')

    expect { @info.undefine('tiff', 'bits-per-sample') }.not_to raise_error
    expect(@info['tiff', 'bits-per-sample']).to be(nil)
    expect { @info.undefine('tiff', 'a' * 10_000) }.to raise_error(ArgumentError)
  end
end
