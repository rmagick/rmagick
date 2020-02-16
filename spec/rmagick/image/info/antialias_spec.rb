RSpec.describe Magick::Image::Info, '#antialias' do
  it 'works' do
    info = described_class.new

    expect(info.antialias).to be(true)
    expect { info.antialias = false }.not_to raise_error
    expect(info.antialias).to be(false)
  end
end
