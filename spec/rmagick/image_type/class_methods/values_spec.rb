RSpec.describe Magick::ImageType, '.values' do
  it 'does not cause an infinite loop' do
    info = Magick::Image::Info.new
    described_class.values do |value|
      info.image_type = value
      expect(info.image_type).to eq(value)
    end
  end
end
