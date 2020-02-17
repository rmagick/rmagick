RSpec.describe Magick::Image, "#color_reset!" do
  it "works" do
    image = described_class.new(20, 20)

    result = image.color_reset!('red')
    expect(result).to be(image)

    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { image.color_reset!(pixel) }.not_to raise_error
    expect { image.color_reset!([2]) }.to raise_error(TypeError)
    expect { image.color_reset!('x') }.to raise_error(ArgumentError)
    image.freeze
    expect { image.color_reset!('red') }.to raise_error(FreezeError)
  end
end
