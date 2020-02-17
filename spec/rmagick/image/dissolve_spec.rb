RSpec.describe Magick::Image, '#dissolve' do
  it 'raises an error given invalid arguments' do
    image1 = described_class.new(100, 100) { self.background_color = 'transparent' }
    image2 = described_class.new(100, 100) { self.background_color = 'green' }

    expect { image1.dissolve }.to raise_error(ArgumentError)
    expect { image1.dissolve(image2, 'x') }.to raise_error(ArgumentError)
    expect { image1.dissolve(image2, 0.50, 'x') }.to raise_error(ArgumentError)
    expect { image1.dissolve(image2, 0.50, Magick::NorthEastGravity, 'x') }.to raise_error(TypeError)
    expect { image1.dissolve(image2, 0.50, Magick::NorthEastGravity, 10, 'x') }.to raise_error(TypeError)
  end

  context 'when given 2 arguments' do
    it 'works when alpha is float 0.0 to 1.0' do
      image1 = described_class.new(100, 100) { self.background_color = 'transparent' }
      image2 = described_class.new(100, 100) { self.background_color = 'green' }

      dissolved = image1.dissolve(image2, 0.50)
      expect(dissolved).to be_instance_of(described_class)
      expect(Float(dissolved.pixel_color(2, 2).alpha) / Magick::QuantumRange).to be_between(0.45, 0.55)
      dissolved = image1.dissolve(image2, 0.20)
      expect(Float(dissolved.pixel_color(2, 2).alpha) / Magick::QuantumRange).to be_between(0.15, 0.25)
    end
    it 'works when alpha is string percentage' do
      image1 = described_class.new(100, 100) { self.background_color = 'transparent' }
      image2 = described_class.new(100, 100) { self.background_color = 'green' }

      dissolved = image1.dissolve(image2, '50%')
      expect(dissolved).to be_instance_of(described_class)
      expect(Float(dissolved.pixel_color(2, 2).alpha) / Magick::QuantumRange).to be_between(0.45, 0.55)
      dissolved = image1.dissolve(image2, '20%')
      expect(Float(dissolved.pixel_color(2, 2).alpha) / Magick::QuantumRange).to be_between(0.15, 0.25)
    end
  end

  context 'when given gravity' do
    # generate an image to use with gravity
    wk = described_class.new(40, 40) { self.background_color = 'transparent' }
    d = Magick::Draw.new
    d.stroke('none').fill('blue')
    d.circle(wk.columns / 2, wk.rows / 2, 4, wk.rows / 2)
    d.draw(wk)

    it 'works on colored background' do
      image = described_class.new(100, 100) { self.background_color = 'green' }

      # generate an image to use with gravity
      dissolved = image.dissolve(wk, 0.50, 1.0, Magick::CenterGravity)
      expect(dissolved).to be_instance_of(described_class)
      expect(dissolved.pixel_color(10, 10)).to eq(image.pixel_color(10, 10))
      expect(Float(dissolved.pixel_color(50, 50).blue) / Magick::QuantumRange).to be_between(0.45, 0.55)
      expect(Float(dissolved.pixel_color(50, 50).green)).to be_between(0, image.pixel_color(2, 2).green).exclusive
    end
  end

  # still need to test with destination percentage, offsets

  it 'raises an error when the image has been destroyed' do
    image1 = described_class.new(100, 100) { self.background_color = 'transparent' }
    image2 = described_class.new(100, 100) { self.background_color = 'green' }

    image1.destroy!
    expect { image1.dissolve(image2, 0.50) }.to raise_error(Magick::DestroyedImageError)
  end
end
