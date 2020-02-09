RSpec.describe Magick::Image::Info, '#filename' do
  before do
    @info = described_class.new
  end

  it 'works' do
    expect { @info.filename = 'string' }.not_to raise_error
    expect(@info.filename).to eq('string')
    expect { @info.filename = nil }.not_to raise_error
    expect(@info.filename).to eq('')
  end
end
