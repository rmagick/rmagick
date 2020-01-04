RSpec.describe Magick::Image, "#color_point" do
  before do
    @img = Magick::Image.new(20, 20)
  end

  it "works" do
    expect do
      res = @img.color_point(0, 0, 'red')
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { @img.color_point(0, 0, pixel) }.not_to raise_error
  end
end
