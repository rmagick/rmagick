RSpec.describe Magick::Image, '#level2' do
  it 'works' do
    image = described_class.new(20, 20)
    image1 = image.level(10, 2, 200)
    image2 = image.level(10, 200, 2)

    expect(image1).to eq(image2)

    # Ensure that level2 uses new arg order
    image1 = image.level2(10, 200, 2)
    expect(image1).to eq(image2)

    expect { image.level2 }.not_to raise_error
    expect { image.level2(10) }.not_to raise_error
    expect { image.level2(10, 10) }.not_to raise_error
    expect { image.level2(10, 10, 10) }.not_to raise_error
    expect { image.level2(10, 10, 10, 10) }.to raise_error(ArgumentError)
  end
end
