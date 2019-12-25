RSpec.describe Magick::OrientationType, '.values' do
  it 'does not cause an infinite loop' do
    info = Magick::Image::Info.new
    Magick::OrientationType.values do |value|
      info.orientation = value
      expect(info.orientation).to eq(value)
    end
  end
end
