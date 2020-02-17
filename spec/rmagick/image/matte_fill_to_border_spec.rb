RSpec.describe Magick::Image, '#matte_fill_to_border' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.matte_fill_to_border(image.columns / 2, image.rows / 2)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.matte_fill_to_border(image.columns, image.rows) }.not_to raise_error
    expect { image.matte_fill_to_border(image.columns + 1, image.rows) }.to raise_error(ArgumentError)
    expect { image.matte_fill_to_border(image.columns, image.rows + 1) }.to raise_error(ArgumentError)
  end
end
