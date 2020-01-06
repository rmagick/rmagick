RSpec.describe Magick::Image::Info, '#units' do
  it 'works' do
    info = described_class.new

    Magick::ResolutionType.values.each do |v|
      expect { info.units = v }.not_to raise_error
      expect(info.units).to eq(v)
    end
  end
end
