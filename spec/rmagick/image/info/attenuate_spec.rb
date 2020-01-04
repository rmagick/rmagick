RSpec.describe Magick::Image::Info, '#attenuate' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    expect { @info.attenuate = 10 }.not_to raise_error
    expect(@info.attenuate).to eq(10)
    expect { @info.attenuate = 5.25 }.not_to raise_error
    expect(@info.attenuate).to eq(5.25)
    expect { @info.attenuate = nil }.not_to raise_error
    expect(@info.attenuate).to be(nil)
  end
end
