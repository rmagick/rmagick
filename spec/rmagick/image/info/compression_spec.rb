RSpec.describe Magick::Image::Info, '#compression' do
  before do
    @info = described_class.new
  end

  it 'works' do
    Magick::CompressionType.values.each do |v|
      expect { @info.compression = v }.not_to raise_error
      expect(@info.compression).to eq(v)
    end
  end
end
