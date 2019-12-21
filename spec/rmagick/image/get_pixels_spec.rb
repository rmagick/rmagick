RSpec.describe Magick::Image, '#get_pixels' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      pixels = @img.get_pixels(0, 0, @img.columns, 1)
      expect(pixels).to be_instance_of(Array)
      expect(pixels.length).to eq(@img.columns)
      expect(pixels.all? { |p| p.is_a? Magick::Pixel }).to be(true)
    end.not_to raise_error
    expect { @img.get_pixels(0,  0, -1, 1) }.to raise_error(RangeError)
    expect { @img.get_pixels(0,  0, @img.columns, -1) }.to raise_error(RangeError)
    expect { @img.get_pixels(0,  0, @img.columns + 1, 1) }.to raise_error(RangeError)
    expect { @img.get_pixels(0,  0, @img.columns, @img.rows + 1) }.to raise_error(RangeError)
  end
end
