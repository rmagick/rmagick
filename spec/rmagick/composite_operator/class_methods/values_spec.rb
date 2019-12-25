RSpec.describe Magick::CompositeOperator, '.values' do
  it 'does not cause an infinite loop' do
    img = Magick::Image.new(10, 10)
    Magick::CompositeOperator.values do |op|
      img.compose = op
      expect(img.compose).to eq(op)
    end
  end
end
