RSpec.describe Magick::Image::Info, '#font' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    expect { @info.font = 'Arial' }.not_to raise_error
    expect(@info.font).to eq('Arial')
    expect { @info.font = nil }.not_to raise_error
    expect(@info.font).to be(nil)
  end
end
