RSpec.describe Magick::Image::Info, '#colorspace' do
  it 'works' do
    info = described_class.new

    Magick::ColorspaceType.values.each do |cs|
      expect { info.colorspace = cs }.not_to raise_error
      expect(info.colorspace).to eq(cs)
    end
  end
end
