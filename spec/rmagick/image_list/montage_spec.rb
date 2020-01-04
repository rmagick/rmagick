RSpec.describe Magick::ImageList, "#montage" do
  before do
    @ilist = Magick::ImageList.new
  end

  it "works" do
    @ilist.read(*Dir[IMAGES_DIR + '/Button_*.gif'])
    ilist = @ilist.copy
    montage = nil
    expect do
      montage = ilist.montage do
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
      expect(montage).to be_instance_of(Magick::ImageList)
      expect(ilist).to eq(@ilist)

      montage_image = montage.first
      expect(montage_image.background_color).to eq('blue')
      expect(montage_image.border_color).to eq('red')
    end.not_to raise_error

    # test illegal option arguments
    # looks like IM doesn't diagnose invalid geometry args
    # to tile= and geometry=
    expect do
      montage = ilist.montage { self.background_color = 2 }
      expect(ilist).to eq(@ilist)
    end.to raise_error(TypeError)
    expect do
      montage = ilist.montage { self.border_color = 2 }
      expect(ilist).to eq(@ilist)
    end.to raise_error(TypeError)
    expect do
      montage = ilist.montage { self.border_width = [2] }
      expect(ilist).to eq(@ilist)
    end.to raise_error(TypeError)
    expect do
      montage = ilist.montage { self.compose = 2 }
      expect(ilist).to eq(@ilist)
    end.to raise_error(TypeError)
    expect do
      montage = ilist.montage { self.filename = 2 }
      expect(ilist).to eq(@ilist)
    end.to raise_error(TypeError)
    expect do
      montage = ilist.montage { self.fill = 2 }
      expect(ilist).to eq(@ilist)
    end.to raise_error(TypeError)
    expect do
      montage = ilist.montage { self.font = 2 }
      expect(ilist).to eq(@ilist)
    end.to raise_error(TypeError)
    expect do
      montage = ilist.montage { self.gravity = 2 }
      expect(ilist).to eq(@ilist)
    end.to raise_error(TypeError)
    expect do
      montage = ilist.montage { self.matte_color = 2 }
      expect(ilist).to eq(@ilist)
    end.to raise_error(TypeError)
    expect do
      montage = ilist.montage { self.pointsize = 'x' }
      expect(ilist).to eq(@ilist)
    end.to raise_error(TypeError)
    expect do
      montage = ilist.montage { self.stroke = 'x' }
      expect(ilist).to eq(@ilist)
    end.to raise_error(ArgumentError)
    expect do
      montage = ilist.montage { self.texture = 'x' }
      expect(ilist).to eq(@ilist)
    end.to raise_error(NoMethodError)
  end
end
