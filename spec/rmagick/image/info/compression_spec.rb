RSpec.describe Magick::Image::Info, '#compression' do
  it 'works' do
    info = described_class.new

    Magick::CompressionType.values.each do |v|
      expect { info.compression = v }.not_to raise_error
      expect(info.compression).to eq(v)
    end
  end
end
