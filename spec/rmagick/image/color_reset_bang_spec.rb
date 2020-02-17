RSpec.describe Magick::Image, "#color_reset!" do
  it "works" do
    img = described_class.new(20, 20)

    res = img.color_reset!('red')
    expect(res).to be(img)

    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { img.color_reset!(pixel) }.not_to raise_error
    expect { img.color_reset!([2]) }.to raise_error(TypeError)
    expect { img.color_reset!('x') }.to raise_error(ArgumentError)
    img.freeze
    expect { img.color_reset!('red') }.to raise_error(FreezeError)
  end
end
