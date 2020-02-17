RSpec.describe Magick::Image, '#implode' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.implode(0.5)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.implode(0.5, 0.5) }.to raise_error(ArgumentError)
  end
end
