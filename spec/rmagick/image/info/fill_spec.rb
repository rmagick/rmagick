RSpec.describe Magick::Image::Info, '#fill' do
  before do
    @info = described_class.new
  end

  it 'works' do
    expect { @info.fill }.not_to raise_error
    expect(@info.fill).to be(nil)

    expect { @info.fill = 'white' }.not_to raise_error
    expect(@info.fill).to eq('white')

    expect { @info.fill = nil }.not_to raise_error
    expect(@info.fill).to be(nil)

    expect { @info.fill = 'xxx' }.to raise_error(ArgumentError)
  end
end
