RSpec.describe Magick::Image, "#color_floodfill" do
  before do
    @img = Magick::Image.new(20, 20)
  end

  it "works" do
    expect { @img.color_floodfill(-1, 1, 'red') }.to raise_error(ArgumentError)
    expect { @img.color_floodfill(1, 100, 'red') }.to raise_error(ArgumentError)
    expect do
      res = @img.color_floodfill(@img.columns / 2, @img.rows / 2, 'red')
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { @img.color_floodfill(@img.columns / 2, @img.rows / 2, pixel) }.not_to raise_error
  end
end
