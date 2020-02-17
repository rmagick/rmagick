RSpec.describe Magick::CompositeOperator, '.values' do
  it 'does not cause an infinite loop' do
    image = Magick::Image.new(10, 10)
    described_class.values do |op|
      image.compose = op
      expect(image.compose).to eq(op)
    end
  end
end
