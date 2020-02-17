RSpec.describe Magick::ImageList, "#montage" do
  def assert_same_image(expected_image_path, image_object, delta: 0.01)
    expected = Magick::Image.read(expected_image_path).first
    _, error = expected.compare_channel(image_object, Magick::MeanSquaredErrorMetric)
    expect(error).to be_within(delta).of(0.0)
  end

  it "works" do
    ilist1 = described_class.new

    ilist1.read(*Dir[IMAGES_DIR + '/Button_*.gif'])
    ilist2 = ilist1.copy

    montage = ilist2.montage do
      self.background_color = Magick::Pixel.new(Magick::QuantumRange, 0, 0)
      self.background_color = 'blue'
      self.border_color = Magick::Pixel.new(0, 0, 0)
      self.border_color = 'red'
      self.border_width = 2
      self.compose = Magick::OverCompositeOp
      self.filename = 'test.png'
      self.fill = 'green'
      self.font = Magick.fonts.first.name
      self.frame = '20x20+4+4'
      self.frame = Magick::Geometry.new(20, 20, 4, 4)
      self.geometry = '63x60+5+5'
      self.geometry = Magick::Geometry.new(63, 60, 5, 5)
      self.gravity = Magick::SouthGravity
      self.matte_color = '#bdbdbd'
      self.matte_color = Magick::Pixel.new(Magick::QuantumRange, 0, 0)
      self.pointsize = 12
      self.shadow = true
      self.stroke = 'transparent'
      self.texture = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
      self.texture = Magick::Image.read(IMAGES_DIR + '/Button_1.gif').first
      self.tile = '4x9'
      self.tile = Magick::Geometry.new(4, 9)
      self.title = 'sample'
    end
    expect(montage).to be_instance_of(described_class)
    expect(ilist2).to eq(ilist1)

    montage_image = montage.first
    expect(montage_image.background_color).to eq('blue')
    expect(montage_image.border_color).to eq('red')

    # test illegal option arguments
    # looks like IM doesn't diagnose invalid geometry args
    # to tile= and geometry=
    expect do
      montage = ilist2.montage { self.background_color = 2 }
      expect(ilist2).to eq(ilist1)
    end.to raise_error(TypeError)
    expect do
      montage = ilist2.montage { self.border_color = 2 }
      expect(ilist2).to eq(ilist1)
    end.to raise_error(TypeError)
    expect do
      montage = ilist2.montage { self.border_width = [2] }
      expect(ilist2).to eq(ilist1)
    end.to raise_error(TypeError)
    expect do
      montage = ilist2.montage { self.compose = 2 }
      expect(ilist2).to eq(ilist1)
    end.to raise_error(TypeError)
    expect do
      montage = ilist2.montage { self.filename = 2 }
      expect(ilist2).to eq(ilist1)
    end.to raise_error(TypeError)
    expect do
      montage = ilist2.montage { self.fill = 2 }
      expect(ilist2).to eq(ilist1)
    end.to raise_error(TypeError)
    expect do
      montage = ilist2.montage { self.font = 2 }
      expect(ilist2).to eq(ilist1)
    end.to raise_error(TypeError)
    expect do
      montage = ilist2.montage { self.gravity = 2 }
      expect(ilist2).to eq(ilist1)
    end.to raise_error(TypeError)
    expect do
      montage = ilist2.montage { self.matte_color = 2 }
      expect(ilist2).to eq(ilist1)
    end.to raise_error(TypeError)
    expect do
      montage = ilist2.montage { self.pointsize = 'x' }
      expect(ilist2).to eq(ilist1)
    end.to raise_error(TypeError)
    expect do
      montage = ilist2.montage { self.stroke = 'x' }
      expect(ilist2).to eq(ilist1)
    end.to raise_error(ArgumentError)
    expect do
      montage = ilist2.montage { self.texture = 'x' }
      expect(ilist2).to eq(ilist1)
    end.to raise_error(NoMethodError)
  end

  it 'montages the image' do
    imagelist = described_class.new(IMAGES_DIR + '/Flower_Hat.jpg')

    new_imagelist = imagelist.montage do
      self.border_width = 100
      self.border_color = 'red'
      self.background_color = 'blue'
      self.matte_color = 'yellow'
      self.frame = '10x10'
      self.gravity = Magick::CenterGravity
    end

    # montage ../../doc/ex/images/Flower_Hat.jpg -border 100x -bordercolor red -mattecolor yellow -background blue -frame 10x10 -gravity Center expected/montage_border_color.jpg
    assert_same_image(File.join(FIXTURE_PATH, 'montage_border_color.jpg'), new_imagelist.first)
  end
end
