RSpec.describe Magick::Image, '#composite' do
  let(:img1) { Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first }
  let(:img2) { Magick::Image.read(IMAGES_DIR + '/Button_1.gif').first }

  it 'raises an error given invalid arguments' do
    expect { img1.composite }.to raise_error(ArgumentError)
    expect { img1.composite(img2) }.to raise_error(ArgumentError)
    expect do
      img1.composite(img2, Magick::NorthWestGravity)
    end.to raise_error(ArgumentError)
    expect { img1.composite(2) }.to raise_error(ArgumentError)
    expect { img1.composite(img2, 2) }.to raise_error(ArgumentError)
  end

  context 'when given 3 arguments' do
    it 'works when 2nd argument is a gravity' do
      Magick::CompositeOperator.values do |op|
        Magick::GravityType.values do |grav|
          expect { img1.composite(img2, grav, op) }.not_to raise_error
        end
      end
    end

    it 'raises an error when 2nd argument is not a gravity' do
      expect do
        img1.composite(img2, 2, Magick::OverCompositeOp)
      end.to raise_error(TypeError)
    end
  end

  context 'when given 4 arguments' do
    it 'works when 4th argument is a composite operator' do
      # there are way too many CompositeOperators to test them all, so just try
      # few representative ops
      Magick::CompositeOperator.values do |op|
        expect { img1.composite(img2, 0, 0, op) }.not_to raise_error
      end
    end

    it 'returns a new Magick::Image object' do
      res = img1.composite(img2, 0, 0, Magick::OverCompositeOp)
      expect(res).to be_instance_of(Magick::Image)
    end

    it 'raises an error when 4th argument is not a composite operator' do
      expect { img1.composite(img2, 0, 0, 2) }.to raise_error(TypeError)
    end
  end

  context 'when given 5 arguments' do
    it 'works when 2nd argument is gravity and 5th is a composite operator' do
      Magick::CompositeOperator.values do |op|
        Magick::GravityType.values do |grav|
          expect { img1.composite(img2, grav, 0, 0, op) }.not_to raise_error
        end
      end
    end

    it 'raises an error when 2nd argument is not a gravity' do
      expect do
        img1.composite(img2, 0, 0, 2, Magick::OverCompositeOp)
      end.to raise_error(TypeError)
    end
  end

  it 'raises an error when the image has been destroyed' do
    img2.destroy!
    expect do
      img1.composite(img2, Magick::CenterGravity, Magick::OverCompositeOp)
    end.to raise_error(Magick::DestroyedImageError)
  end
end
