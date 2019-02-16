class Magick::Draw
  def self._dummy_img_
    @@_dummy_img_
  end
end

RSpec.describe Magick::Draw do
  let(:draw) { described_class.new }

  describe '._dummy_img_' do
    it 'works' do
      # initially this variable is not defined.
      expect { described_class._dummy_img_ }.to raise_error(NameError)

      # cause it to become defined. save the object id.
      draw.get_type_metrics('ABCDEF')
      dummy = nil
      expect { dummy = described_class._dummy_img_ }.not_to raise_error

      expect(dummy).to be_instance_of(Magick::Image)

      # ensure that it is always the same object
      draw.get_type_metrics('ABCDEF')
      dummy2 = nil
      expect { dummy2 = described_class._dummy_img_ }.not_to raise_error
      expect(dummy).to eq dummy2
    end
  end

  describe '#kerning=' do
    it 'assigns without raising an error' do
      expect { draw.kerning = 1 }.not_to raise_error
    end
  end

  describe '#kerning' do
    it 'accepts a valid parameter without raising an error' do
      expect { draw.kerning(1) }.not_to raise_error
    end

    it 'raises an error when given an invalid parameter' do
      expect { draw.kerning('a') }.to raise_error(ArgumentError)
      expect { draw.kerning([]) }.to raise_error(TypeError)
    end
  end

  describe '#interline_spacing=' do
    it 'assigns without raising an error' do
      expect { draw.interline_spacing = 1 }.not_to raise_error
    end
  end

  describe '#interline_spacing' do
    it 'accepts a valid parameter without raising an error' do
      expect { draw.interline_spacing(1) }.not_to raise_error
    end

    it 'raises an error when given an invalid parameter' do
      expect { draw.interline_spacing('a') }.to raise_error(ArgumentError)
      expect { draw.interline_spacing([]) }.to raise_error(TypeError)
    end
  end

  describe '#interword_spacing=' do
    it 'assigns without raising an error' do
      expect { draw.interword_spacing = 1 }.not_to raise_error
    end
  end

  describe '#interword_spacing' do
    it 'accepts a valid parameter without raising an error' do
      expect { draw.interword_spacing(1) }.not_to raise_error
    end

    it 'raises an error when given an invalid parameter' do
      expect { draw.interword_spacing('a') }.to raise_error(ArgumentError)
      expect { draw.interword_spacing([]) }.to raise_error(TypeError)
    end
  end

  describe '#marshal_dump', '#marshal_load' do
    it 'marshals without an error' do
      skip 'this spec fails on some versions of ImageMagick'
      granite = Magick::Image.read('granite:').first
      s = granite.to_blob { self.format = 'miff' }
      granite = Magick::Image.from_blob(s).first
      blue_stroke = Magick::Image.new(20, 20) { self.background_color = 'blue' }
      s = blue_stroke.to_blob { self.format = 'miff' }
      blue_stroke = Magick::Image.from_blob(s).first

      draw.affine = Magick::AffineMatrix.new(1, 2, 3, 4, 5, 6)
      draw.decorate = Magick::LineThroughDecoration
      draw.encoding = 'AdobeCustom'
      draw.gravity = Magick::CenterGravity
      draw.fill = Magick::Pixel.from_color('red')
      draw.stroke = Magick::Pixel.from_color('blue')
      draw.stroke_width = 5
      draw.fill_pattern = granite
      draw.stroke_pattern = blue_stroke
      draw.text_antialias = true
      draw.font = 'Arial-Bold'
      draw.font_family = 'arial'
      draw.font_style = Magick::ItalicStyle
      draw.font_stretch = Magick::CondensedStretch
      draw.font_weight = Magick::BoldWeight
      draw.pointsize = 12
      draw.density = '72x72'
      draw.align = Magick::CenterAlign
      draw.undercolor = Magick::Pixel.from_color('green')
      draw.kerning = 10.5
      draw.interword_spacing = 3.75

      draw.circle(20, 25, 20, 28)
      dumped = nil
      expect { dumped = Marshal.dump(draw) }.not_to raise_error
      expect { Marshal.load(dumped) }.not_to raise_error
    end
  end

  describe '#fill_pattern' do
    it 'accepts an Image argument' do
      img = Magick::Image.new(20, 20)
      expect { draw.fill_pattern = img }.not_to raise_error
    end

    it 'accepts an ImageList argument' do
      img = Magick::Image.new(20, 20)
      ilist = Magick::ImageList.new
      ilist << img
      expect { draw.fill_pattern = ilist }.not_to raise_error
    end

    it 'does not accept arbitrary arguments' do
      expect { draw.fill_pattern = 1 }.to raise_error(NoMethodError)
    end
  end

  describe '#stroke_pattern' do
    it 'accepts an Image argument' do
      img = Magick::Image.new(20, 20)
      expect { draw.stroke_pattern = img }.not_to raise_error
    end

    it 'accepts an ImageList argument' do
      img = Magick::Image.new(20, 20)
      ilist = Magick::ImageList.new
      ilist << img
      expect { draw.stroke_pattern = ilist }.not_to raise_error
    end

    it 'does not accept arbitrary arguments' do
      expect { draw.stroke_pattern = 1 }.to raise_error(NoMethodError)
    end
  end
end
