RSpec.describe Magick::Image::Info, '#format' do
  it 'works' do
    info = described_class.new

    expect { info.format = 'GIF' }.not_to raise_error
    expect(info.format).to eq('GIF')
    expect { info.format = nil }.to raise_error(TypeError)
  end
end
