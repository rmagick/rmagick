RSpec.describe Magick::Image, '#contrast' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.contrast
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.contrast(true) }.not_to raise_error
    expect { image.contrast(true, 2) }.to raise_error(ArgumentError)
  end
end
