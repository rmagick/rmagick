RSpec.describe Magick::Image::Info, '#interlace' do
  it 'works' do
    info = described_class.new

    Magick::InterlaceType.values.each do |v|
      expect { info.interlace = v }.not_to raise_error
      expect(info.interlace).to eq(v)
    end
    expect { info.interlace = nil }.to raise_error(TypeError)
  end
end
