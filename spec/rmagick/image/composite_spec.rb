RSpec.describe Magick::Image, '#composite' do
  it 'raises an error given invalid arguments' do
    image1 = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    image2 = described_class.read(IMAGES_DIR + '/Button_1.gif').first

    expect { image1.composite }.to raise_error(ArgumentError)
    expect { image1.composite(image2) }.to raise_error(ArgumentError)
    expect do
      image1.composite(image2, Magick::NorthWestGravity)
    end.to raise_error(ArgumentError)
    expect { image1.composite(2) }.to raise_error(ArgumentError)
    expect { image1.composite(image2, 2) }.to raise_error(ArgumentError)
  end

  context 'when given 3 arguments' do
    it 'works when 2nd argument is a gravity' do
      image1 = described_class.read(IMAGES_DIR + '/Button_0.gif').first
      image2 = described_class.read(IMAGES_DIR + '/Button_1.gif').first

      Magick::CompositeOperator.values do |op|
        Magick::GravityType.values do |grav|
          expect { image1.composite(image2, grav, op) }.not_to raise_error
        end
      end
    end

    it 'accepts an ImageList argument' do
      image = described_class.new(20, 20)

      image_list = Magick::ImageList.new
      image_list.new_image(10, 10)
      expect { image.composite(image_list, Magick::NorthWestGravity, Magick::OverCompositeOp) }.not_to raise_error
    end

    it 'raises an error when 2nd argument is not a gravity' do
      image1 = described_class.read(IMAGES_DIR + '/Button_0.gif').first
      image2 = described_class.read(IMAGES_DIR + '/Button_1.gif').first

      expect do
        image1.composite(image2, 2, Magick::OverCompositeOp)
      end.to raise_error(TypeError)
    end
  end

  context 'when given 4 arguments' do
    it 'works when 4th argument is a composite operator' do
      image1 = described_class.read(IMAGES_DIR + '/Button_0.gif').first
      image2 = described_class.read(IMAGES_DIR + '/Button_1.gif').first

      # there are way too many CompositeOperators to test them all, so just try
      # few representative ops
      Magick::CompositeOperator.values do |op|
        expect { image1.composite(image2, 0, 0, op) }.not_to raise_error
      end
    end

    it 'accepts an ImageList argument' do
      image = described_class.new(20, 20)

      image_list = Magick::ImageList.new
      image_list.new_image(10, 10)
      expect { image.composite(image_list, 0, 0, Magick::OverCompositeOp) }.not_to raise_error
    end

    it 'returns a new Magick::Image object' do
      image1 = described_class.read(IMAGES_DIR + '/Button_0.gif').first
      image2 = described_class.read(IMAGES_DIR + '/Button_1.gif').first

      result = image1.composite(image2, 0, 0, Magick::OverCompositeOp)
      expect(result).to be_instance_of(described_class)
    end

    it 'raises an error when 4th argument is not a composite operator' do
      image1 = described_class.read(IMAGES_DIR + '/Button_0.gif').first
      image2 = described_class.read(IMAGES_DIR + '/Button_1.gif').first

      expect { image1.composite(image2, 0, 0, 2) }.to raise_error(TypeError)
    end
  end

  context 'when given 5 arguments' do
    it 'works when 2nd argument is gravity and 5th is a composite operator' do
      image1 = described_class.read(IMAGES_DIR + '/Button_0.gif').first
      image2 = described_class.read(IMAGES_DIR + '/Button_1.gif').first

      Magick::CompositeOperator.values do |op|
        Magick::GravityType.values do |grav|
          expect { image1.composite(image2, grav, 0, 0, op) }.not_to raise_error
        end
      end
    end

    it 'accepts an ImageList argument' do
      image = described_class.new(20, 20)

      image_list = Magick::ImageList.new
      image_list.new_image(10, 10)
      expect { image.composite(image_list, Magick::NorthWestGravity, 0, 0, Magick::OverCompositeOp) }.not_to raise_error
    end

    it 'raises an error when 2nd argument is not a gravity' do
      image1 = described_class.read(IMAGES_DIR + '/Button_0.gif').first
      image2 = described_class.read(IMAGES_DIR + '/Button_1.gif').first

      expect do
        image1.composite(image2, 0, 0, 2, Magick::OverCompositeOp)
      end.to raise_error(TypeError)
    end
  end

  it 'raises an error when the image has been destroyed' do
    image1 = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    image2 = described_class.read(IMAGES_DIR + '/Button_1.gif').first

    image2.destroy!
    expect do
      image1.composite(image2, Magick::CenterGravity, Magick::OverCompositeOp)
    end.to raise_error(Magick::DestroyedImageError)
  end
end
