RSpec.describe Magick::Image::Info, '#define' do
  before do
    @info = described_class.new
  end

  it 'works' do
    expect { @info.define('tiff', 'bits-per-sample', 2) }.not_to raise_error
    expect { @info.undefine('tiff', 'bits-per-sample') }.not_to raise_error
    expect { @info.define('tiff', 'bits-per-sample', 2, 2) }.to raise_error(ArgumentError)
    expect { @info.define('tiff', 'a' * 10_000) }.to raise_error(ArgumentError)
  end
end
