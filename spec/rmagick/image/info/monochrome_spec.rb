RSpec.describe Magick::Image::Info, '#monochrome' do
  before do
    @info = described_class.new
  end

  it 'works' do
    expect { @info.monochrome = true }.not_to raise_error
    expect(@info.monochrome).to be(true)
    expect { @info.monochrome = nil }.not_to raise_error
  end
end
