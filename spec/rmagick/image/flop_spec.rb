RSpec.describe Magick::Image, '#flop' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.flop
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)
  end
end
