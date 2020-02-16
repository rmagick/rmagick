RSpec.describe Magick::Image::Info, '#filename' do
  it 'works' do
    info = described_class.new

    expect { info.filename = 'string' }.not_to raise_error
    expect(info.filename).to eq('string')
    expect { info.filename = nil }.not_to raise_error
    expect(info.filename).to eq('')
  end
end
