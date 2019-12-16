RSpec.describe Magick::Image, '#pixel_color' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.pixel_color(0, 0)
      expect(res).to be_instance_of(Magick::Pixel)
    end.not_to raise_error
    res = @img.pixel_color(0, 0)
    expect(res.to_color).to eq(@img.background_color)
    res = @img.pixel_color(0, 0, 'red')
    expect(res.to_color).to eq('white')
    res = @img.pixel_color(0, 0)
    expect(res.to_color).to eq('red')

    blue = Magick::Pixel.new(0, 0, Magick::QuantumRange)
    expect { @img.pixel_color(0, 0, blue) }.not_to raise_error
    # If args are out-of-bounds return the background color
    img = Magick::Image.new(10, 10) { self.background_color = 'blue' }
    expect(img.pixel_color(50, 50).to_color).to eq('blue')

    expect do
      @img.class_type = Magick::PseudoClass
      res = @img.pixel_color(0, 0, 'red')
      expect(res.to_color).to eq('blue')
    end.not_to raise_error
  end
end
