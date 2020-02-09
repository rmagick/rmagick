RSpec.describe Magick::ClassType, '.values' do
  it 'does not cause an infinite loop' do
    img = Magick::Image.new(1, 1)
    described_class.values do |value|
      next if value == Magick::UndefinedClass

      img.class_type = value
      expect(img.class_type).to eq(value)
    end
  end
end
