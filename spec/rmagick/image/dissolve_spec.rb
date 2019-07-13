RSpec.describe Magick::Image, '#dissolve' do
  let(:img1) { Magick::Image.new(100, 100) { self.background_color = 'transparent' } }
  let(:img2) { Magick::Image.new(100, 100) { self.background_color = 'green' } }
  
  it 'raises an error given invalid arguments' do
    expect { img1.dissolve }.to raise_error(ArgumentError)
    expect { img1.dissolve(img2, 'x') }.to raise_error(ArgumentError)
    expect { img1.dissolve(img2, 0.50, 'x') }.to raise_error(ArgumentError)
    expect { img1.dissolve(img2, 0.50, Magick::NorthEastGravity, 'x') }.to raise_error(TypeError)
    expect { img1.dissolve(img2, 0.50, Magick::NorthEastGravity, 10, 'x') }.to raise_error(TypeError)
  end
  
  
  context 'when given 2 arguments' do
    it 'works when alpha is float 0.0 to 1.0' do
      dissolved = img1.dissolve(img2, 0.50)
      expect(dissolved).to be_instance_of(Magick::Image)
      expect(dissolved.pixel_color(2,2).alpha.to_f / Magick::QuantumRange).to be_between(0.45, 0.55)
      dissolved = img1.dissolve(img2, 0.20)
      expect(dissolved.pixel_color(2,2).alpha.to_f / Magick::QuantumRange).to be_between(0.15, 0.25)
    end
    it 'works when alpha is string percentage' do
      dissolved = img1.dissolve(img2, '50%')
      expect(dissolved).to be_instance_of(Magick::Image)
      expect(dissolved.pixel_color(2,2).alpha.to_f / Magick::QuantumRange).to be_between(0.45, 0.55)
      dissolved = img1.dissolve(img2, '20%')
      expect(dissolved.pixel_color(2,2).alpha.to_f / Magick::QuantumRange).to be_between(0.15, 0.25)
    end
  end
  
  context 'when given gravity' do
    # generate an image to use with gravity
    wk = Magick::Image.new(40, 40) { self.background_color = 'transparent' }
    d = Magick::Draw.new
    d.stroke('none').fill('blue')
    d.circle(wk.columns/2,wk.rows/2, 4,wk.rows/2)
    d.draw(wk)
    
    it 'works on colored background' do
      # generate an image to use with gravity
      dissolved = img2.dissolve(wk, 0.50, 1.0, Magick::CenterGravity)
      expect(dissolved).to be_instance_of(Magick::Image)
      expect(dissolved.pixel_color(10,10)).to eq(img2.pixel_color(10,10))
      expect(dissolved.pixel_color(50,50).blue.to_f / Magick::QuantumRange).to be_between(0.45, 0.55)
      expect(dissolved.pixel_color(50,50).green.to_f).to be_between(0, img2.pixel_color(2,2).green).exclusive
    end
  end
  
  # still need to test with destination percentage, offsets


  it 'raises an error when the image has been destroyed' do
    img1.destroy!
    expect do
      img1.dissolve(img2, 0.50)
    end.to raise_error(Magick::DestroyedImageError)
  end
end
