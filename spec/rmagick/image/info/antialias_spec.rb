RSpec.describe Magick::Image::Info, '#antialias' do
  before do
    @info = described_class.new
  end

  it 'works' do
    expect(@info.antialias).to be(true)
    expect { @info.antialias = false }.not_to raise_error
    expect(@info.antialias).to be(false)
  end
end
