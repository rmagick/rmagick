RSpec.describe Magick::Image::Info, '#label' do
  it 'works' do
    info = described_class.new

    expect { info.label = 'string' }.not_to raise_error
    expect(info.label).to eq('string')
    expect { info.label = nil }.not_to raise_error
    expect(info.label).to be(nil)
  end
end
