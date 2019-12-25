RSpec.describe Magick::ResolutionType, '.values' do
  it 'does not cause an infinite loop' do
    info = Magick::Image::Info.new
    Magick::ResolutionType.values do |value|
      info.units = value
      expect(info.units).to eq(value)
    end
  end
end
