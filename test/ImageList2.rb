require 'fileutils'
require 'rmagick'
require 'minitest/autorun'

describe Magick::ImageList do
  before do
    @ilist = Magick::ImageList.new
  end

  describe "#append" do
    it "works" do
      @ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_0.gif')
      expect do
        img = @ilist.append(true)
        expect(img).to be_instance_of(Magick::Image)
      end.not_to raise_error
      expect do
        img = @ilist.append(false)
        expect(img).to be_instance_of(Magick::Image)
      end.not_to raise_error
      expect { @ilist.append }.to raise_error(ArgumentError)
      expect { @ilist.append(true, 1) }.to raise_error(ArgumentError)
    end
  end

  describe "#average" do
    it "works" do
      @ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_0.gif')
      expect do
        img = @ilist.average
        expect(img).to be_instance_of(Magick::Image)
      end.not_to raise_error
      expect { @ilist.average(1) }.to raise_error(ArgumentError)
    end
  end

  describe "#clone" do
    it "works" do
      @ilist.read(*Dir[IMAGES_DIR + '/Button_*.gif'])
      ilist2 = @ilist.clone
      expect(@ilist).to eq(ilist2)
      expect(ilist2.frozen?).to eq(@ilist.frozen?)
      expect(ilist2.tainted?).to eq(@ilist.tainted?)
      @ilist.taint
      @ilist.freeze
      ilist2 = @ilist.clone
      expect(ilist2.frozen?).to eq(@ilist.frozen?)
      expect(ilist2.tainted?).to eq(@ilist.tainted?)
    end
  end

  describe "#coalesce" do
    it "works" do
      @ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_0.gif')
      ilist = nil
      expect { ilist = @ilist.coalesce }.not_to raise_error
      expect(ilist).to be_instance_of(Magick::ImageList)
      expect(ilist.length).to eq(2)
      expect(ilist.scene).to eq(0)
    end
  end

  describe "#copy" do
    it "works" do
      @ilist.read(*Dir[IMAGES_DIR + '/Button_*.gif'])
      @ilist.scene = 7
      ilist2 = @ilist.copy
      expect(ilist2).not_to be(@ilist)
      expect(ilist2.scene).to eq(@ilist.scene)
      @ilist.each_with_index do |img, x|
        expect(ilist2[x]).to eq(img)
      end
    end
  end

  describe "#deconstruct" do
    it "works" do
      @ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')
      ilist = nil
      expect { ilist = @ilist.deconstruct }.not_to raise_error
      expect(ilist).to be_instance_of(Magick::ImageList)
      expect(ilist.length).to eq(2)
      expect(ilist.scene).to eq(0)
    end
  end

  describe "#dup" do
    it "works" do
      @ilist.read(*Dir[IMAGES_DIR + '/Button_*.gif'])
      ilist2 = @ilist.dup
      expect(@ilist).to eq(ilist2)
      expect(ilist2.frozen?).to eq(@ilist.frozen?)
      expect(ilist2.tainted?).to eq(@ilist.tainted?)
      @ilist.taint
      @ilist.freeze
      ilist2 = @ilist.dup
      expect(ilist2.frozen?).not_to eq(@ilist.frozen?)
      expect(ilist2.tainted?).to eq(@ilist.tainted?)
    end
  end

  describe "#flatten_images" do
    it "works" do
      @ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')
      expect do
        img = @ilist.flatten_images
        expect(img).to be_instance_of(Magick::Image)
      end.not_to raise_error
    end
  end

  describe "#from_blob" do
    it "works" do
      hat = File.open(FLOWER_HAT, 'rb')
      blob = hat.read
      expect { @ilist.from_blob(blob) }.not_to raise_error
      expect(@ilist[0]).to be_instance_of(Magick::Image)
      expect(@ilist.scene).to eq(0)

      ilist2 = Magick::ImageList.new(FLOWER_HAT)
      expect(ilist2).to eq(@ilist)
    end
  end

  describe "#marshal" do
    it "works" do
      ilist1 = Magick::ImageList.new(*Dir[IMAGES_DIR + '/Button_*.gif'])
      d = nil
      ilist2 = nil
      expect { d = Marshal.dump(ilist1) }.not_to raise_error
      expect { ilist2 = Marshal.load(d) }.not_to raise_error
      expect(ilist2).to eq(ilist1)
    end
  end

  describe "#montage" do
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

  describe "#morph" do
    it "works" do
      # can't morph an empty list
      expect { @ilist.morph(1) }.to raise_error(ArgumentError)
      @ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')
      # can't specify a negative argument
      expect { @ilist.morph(-1) }.to raise_error(ArgumentError)
      expect do
        res = @ilist.morph(2)
        expect(res).to be_instance_of(Magick::ImageList)
        expect(res.length).to eq(4)
        expect(res.scene).to eq(0)
      end.not_to raise_error
    end
  end

  describe "#mosaic" do
    it "works" do
      @ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')
      expect do
        res = @ilist.mosaic
        expect(res).to be_instance_of(Magick::Image)
      end.not_to raise_error
    end
  end

  describe "#mosaic_with_invalid_imagelist" do
    it "works" do
      list = @ilist.copy
      list.instance_variable_set("@images", nil)
      expect { list.mosaic }.to raise_error(Magick::ImageMagickError)
    end
  end

  describe "#new_image" do
    it "works" do
      expect do
        @ilist.new_image(20, 20)
      end.not_to raise_error
      expect(@ilist.length).to eq(1)
      expect(@ilist.scene).to eq(0)
      @ilist.new_image(20, 20, Magick::HatchFill.new('black'))
      expect(@ilist.length).to eq(2)
      expect(@ilist.scene).to eq(1)
      @ilist.new_image(20, 20) { self.background_color = 'red' }
      expect(@ilist.length).to eq(3)
      expect(@ilist.scene).to eq(2)
    end
  end

  describe "#optimize_layers" do
    it "works" do
      @ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')
      Magick::LayerMethod.values do |method|
        next if [Magick::UndefinedLayer, Magick::CompositeLayer, Magick::TrimBoundsLayer].include?(method)

        expect do
          res = @ilist.optimize_layers(method)
          expect(res).to be_instance_of(Magick::ImageList)
          expect(res.length).to be_kind_of(Integer)
        end.not_to raise_error
      end

      expect { @ilist.optimize_layers(Magick::CompareClearLayer) }.not_to raise_error
      expect { @ilist.optimize_layers(Magick::UndefinedLayer) }.to raise_error(ArgumentError)
      expect { @ilist.optimize_layers(2) }.to raise_error(TypeError)
      expect { @ilist.optimize_layers(Magick::CompositeLayer) }.to raise_error(NotImplementedError)
    end
  end

  describe "#ping" do
    it "works" do
      expect { @ilist.ping(FLOWER_HAT) }.not_to raise_error
      expect(@ilist.length).to eq(1)
      expect(@ilist.scene).to eq(0)
      expect { @ilist.ping(FLOWER_HAT, FLOWER_HAT) }.not_to raise_error
      expect(@ilist.length).to eq(3)
      expect(@ilist.scene).to eq(2)
      expect { @ilist.ping(FLOWER_HAT) { self.background_color = 'red ' } }.not_to raise_error
      expect(@ilist.length).to eq(4)
      expect(@ilist.scene).to eq(3)
    end
  end

  describe "#quantize" do
    it "works" do
      @ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')
      expect do
        res = @ilist.quantize
        expect(res).to be_instance_of(Magick::ImageList)
        expect(res.scene).to eq(1)
      end.not_to raise_error
      expect { @ilist.quantize(128) }.not_to raise_error
      expect { @ilist.quantize('x') }.to raise_error(TypeError)
      expect { @ilist.quantize(128, Magick::RGBColorspace) }.not_to raise_error
      expect { @ilist.quantize(128, 'x') }.to raise_error(TypeError)
      expect { @ilist.quantize(128, Magick::RGBColorspace, true, 0) }.not_to raise_error
      expect { @ilist.quantize(128, Magick::RGBColorspace, true) }.not_to raise_error
      expect { @ilist.quantize(128, Magick::RGBColorspace, false) }.not_to raise_error
      expect { @ilist.quantize(128, Magick::RGBColorspace, Magick::NoDitherMethod) }.not_to raise_error
      expect { @ilist.quantize(128, Magick::RGBColorspace, Magick::RiemersmaDitherMethod) }.not_to raise_error
      expect { @ilist.quantize(128, Magick::RGBColorspace, Magick::FloydSteinbergDitherMethod) }.not_to raise_error
      expect { @ilist.quantize(128, Magick::RGBColorspace, Magick::FloydSteinbergDitherMethod, 32) }.not_to raise_error
      expect { @ilist.quantize(128, Magick::RGBColorspace, Magick::FloydSteinbergDitherMethod, 32, true) }.not_to raise_error
      expect { @ilist.quantize(128, Magick::RGBColorspace, Magick::FloydSteinbergDitherMethod, 32, false) }.not_to raise_error
      expect { @ilist.quantize(128, Magick::RGBColorspace, true, 'x') }.to raise_error(TypeError)
      expect { @ilist.quantize(128, Magick::RGBColorspace, true, 0, false, 'extra') }.to raise_error(ArgumentError)
    end
  end

  describe "#read" do
    it "works" do
      expect { @ilist.read(FLOWER_HAT) }.not_to raise_error
      expect(@ilist.length).to eq(1)
      expect(@ilist.scene).to eq(0)
      expect { @ilist.read(FLOWER_HAT, FLOWER_HAT) }.not_to raise_error
      expect(@ilist.length).to eq(3)
      expect(@ilist.scene).to eq(2)
      expect { @ilist.read(FLOWER_HAT) { self.background_color = 'red ' } }.not_to raise_error
      expect(@ilist.length).to eq(4)
      expect(@ilist.scene).to eq(3)
    end
  end

  describe "#remap" do
    it "works" do
      @ilist.read(*Dir[IMAGES_DIR + '/Button_*.gif'])
      expect { @ilist.remap }.not_to raise_error
      remap_image = Magick::Image.new(20, 20) { self.background_color = 'green' }
      expect { @ilist.remap(remap_image) }.not_to raise_error
      expect { @ilist.remap(remap_image, Magick::NoDitherMethod) }.not_to raise_error
      expect { @ilist.remap(remap_image, Magick::RiemersmaDitherMethod) }.not_to raise_error
      expect { @ilist.remap(remap_image, Magick::FloydSteinbergDitherMethod) }.not_to raise_error
      expect { @ilist.remap(remap_image, Magick::NoDitherMethod, 1) }.to raise_error(ArgumentError)

      remap_image.destroy!
      expect { @ilist.remap(remap_image) }.to raise_error(Magick::DestroyedImageError)
      # expect { @ilist.affinity(affinity_image, 1) }.to raise_error(TypeError)
    end
  end

  describe "#to_blob" do
    it "works" do
      @ilist.read(IMAGES_DIR + '/Button_0.gif')
      blob = nil
      expect { blob = @ilist.to_blob }.not_to raise_error
      img = @ilist.from_blob(blob)
      expect(img[0]).to eq(@ilist[0])
      expect(img.scene).to eq(1)
    end
  end

  describe "#write" do
    it "works" do
      @ilist.read(IMAGES_DIR + '/Button_0.gif')
      expect do
        @ilist.write('temp.gif')
      end.not_to raise_error
      list = Magick::ImageList.new('temp.gif')
      expect(list.format).to eq('GIF')
      FileUtils.rm('temp.gif')

      @ilist.write('jpg:temp.foo')
      list = Magick::ImageList.new('temp.foo')
      expect(list.format).to eq('JPEG')
      FileUtils.rm('temp.foo')

      @ilist.write('temp.0') { self.format = 'JPEG' }
      list = Magick::ImageList.new('temp.0')
      expect(list.format).to eq('JPEG')
      FileUtils.rm('temp.0')

      f = File.new('test.0', 'w')
      @ilist.write(f) { self.format = 'JPEG' }
      f.close
      list = Magick::ImageList.new('test.0')
      expect(list.format).to eq('JPEG')
      FileUtils.rm('test.0')
    end
  end
end

if $PROGRAM_NAME == __FILE__
  IMAGES_DIR = '../doc/ex/images'
  FLOWER_HAT = IMAGES_DIR + '/Flower_Hat.jpg'
  Test::Unit::UI::Console::TestRunner.run(ImageList2UT)
end
