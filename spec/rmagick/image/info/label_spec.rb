RSpec.describe Magick::Image::Info, '#label' do
  before do
    @info = described_class.new
  end

  it 'works' do
    expect { @info.label = 'string' }.not_to raise_error
    expect(@info.label).to eq('string')
    expect { @info.label = nil }.not_to raise_error
    expect(@info.label).to be(nil)
  end
end
