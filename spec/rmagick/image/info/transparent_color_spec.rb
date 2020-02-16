RSpec.describe Magick::Image::Info, '#transparent_color' do
  it 'works' do
    info = described_class.new

    expect { info.transparent_color = 'white' }.not_to raise_error
    expect(info.transparent_color).to eq('white')
    expect { info.transparent_color = nil }.to raise_error(TypeError)
  end
end
