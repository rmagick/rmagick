RSpec.describe Magick::InterlaceType, '.values' do
  it 'does not cause an infinite loop' do
    info = Magick::Image::Info.new
    described_class.values do |value|
      info.interlace = value
      expect(info.interlace).to eq(value)
    end
  end
end
