RSpec.describe Magick::Image, '#oil_paint' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.oil_paint
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.oil_paint(2.0) }.not_to raise_error
    expect { image.oil_paint(2.0, 1.0) }.to raise_error(ArgumentError)
  end
end
