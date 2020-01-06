RSpec.describe Magick::Image::Info, '#caption' do
  it 'works' do
    info = described_class.new

    expect { info.caption = 'string' }.not_to raise_error
    expect(info.caption).to eq('string')
    expect { info.caption = nil }.not_to raise_error
    expect(info.caption).to be(nil)
    expect { Magick::Image.new(20, 20) { self.caption = 'string' } }.not_to raise_error
  end
end
