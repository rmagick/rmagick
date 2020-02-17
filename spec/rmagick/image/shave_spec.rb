RSpec.describe Magick::Image, '#shave' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.shave(5, 5)
    expect(result).to be_instance_of(described_class)
  end
end
