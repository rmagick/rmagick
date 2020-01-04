RSpec.describe Magick::Image, "#color_reset!" do
  before do
    @img = Magick::Image.new(20, 20)
  end

  it "works" do
    expect do
      res = @img.color_reset!('red')
      expect(res).to be(@img)
    end.not_to raise_error
    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { @img.color_reset!(pixel) }.not_to raise_error
    expect { @img.color_reset!([2]) }.to raise_error(TypeError)
    expect { @img.color_reset!('x') }.to raise_error(ArgumentError)
    @img.freeze
    expect { @img.color_reset!('red') }.to raise_error(FreezeError)
  end
end
