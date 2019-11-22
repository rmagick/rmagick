RSpec.describe Magick::Enum do
  describe '#new' do
    it 'works' do
      expect { Magick::Enum.new(:foo, 42) }.not_to raise_error
      expect { Magick::Enum.new('foo', 42) }.not_to raise_error

      expect { Magick::Enum.new(Object.new, 42) }.to raise_error(TypeError)
      expect { Magick::Enum.new(:foo, 'x') }.to raise_error(TypeError)
    end
  end

  describe '#to_s' do
    it 'works' do
      enum = Magick::Enum.new(:foo, 42)
      expect(enum.to_s).to eq('foo')

      enum = Magick::Enum.new('foo', 42)
      expect(enum.to_s).to eq('foo')
    end
  end

  describe '#to_i' do
    it 'works' do
      enum = Magick::Enum.new(:foo, 42)
      expect(enum.to_i).to eq(42)
    end
  end

  describe '#spaceship' do
    it 'works' do
      enum1 = Magick::Enum.new(:foo, 42)
      enum2 = Magick::Enum.new(:foo, 56)
      enum3 = Magick::Enum.new(:foo, 36)
      enum4 = Magick::Enum.new(:foo, 42)

      expect(enum1 <=> enum2).to eq(-1)
      expect(enum1 <=> enum4).to eq(0)
      expect(enum1 <=> enum3).to eq(1)
      expect(enum1 <=> 'x').to be(nil)
    end
  end

  describe '#case_eq' do
    it 'works' do
      enum1 = Magick::Enum.new(:foo, 42)
      enum2 = Magick::Enum.new(:foo, 56)

      expect(enum1 === enum1).to be(true)
      expect(enum1 === enum2).to be(false)
      expect(enum1 === 'x').to be(false)
    end
  end

  describe '#bitwise_or' do
    it 'works' do
      enum1 = Magick::Enum.new(:foo, 42)
      enum2 = Magick::Enum.new(:bar, 56)

      enum = enum1 | enum2
      expect(enum.to_i).to eq(58)
      expect(enum.to_s).to eq('foo|bar')

      expect { enum1 | 'x' }.to raise_error(ArgumentError)
    end
  end

  describe '#type_values' do
    it 'works' do
      expect(Magick::AlignType.values).to be_instance_of(Array)

      expect(Magick::AlignType.values[0].to_s).to eq('UndefinedAlign')
      expect(Magick::AlignType.values[0].to_i).to eq(0)

      Magick::AlignType.values do |enum|
        expect(enum).to be_kind_of(Magick::Enum)
        expect(enum).to be_instance_of(Magick::AlignType)
      end
    end
  end

  describe '#type_inspect' do
    it 'works' do
      expect(Magick::AlignType.values[0].inspect).to eq('UndefinedAlign=0')
    end
  end

  describe '#using_compose_does_not_cause_endless_loop' do
    it 'works' do
      img = Magick::Image.new(10, 10)
      Magick::CompositeOperator.values do |op|
        img.compose = op
        expect(img.compose).to eq(op)
      end
    end
  end

  describe '#using_class_type_does_not_cause_endless_loop' do
    it 'works' do
      img = Magick::Image.new(1, 1)
      Magick::ClassType.values do |value|
        next if value == Magick::UndefinedClass

        img.class_type = value
        expect(img.class_type).to eq(value)
      end
    end
  end

  describe '#using_colorspace_type_does_not_cause_endless_loop' do
    it 'works' do
      img = Magick::Image.new(1, 1)
      Magick::ColorspaceType.values do |value|
        next if value == Magick::SRGBColorspace

        expect(img.colorspace).not_to eq(value)
      end
    end
  end

  describe '#using_compression_type_does_not_cause_endless_loop' do
    it 'works' do
      img = Magick::Image.new(1, 1)
      Magick::CompressionType.values do |value|
        img.compression = value
        expect(img.compression).to eq(value)
      end
    end
  end

  describe '#using_dispose_type_does_not_cause_endless_loop' do
    it 'works' do
      img = Magick::Image.new(1, 1)
      Magick::DisposeType.values do |value|
        img.dispose = value
        expect(img.dispose).to eq(value)
      end
    end
  end

  describe '#using_endian_type_does_not_cause_endless_loop' do
    it 'works' do
      img = Magick::Image.new(1, 1)
      Magick::EndianType.values do |value|
        img.endian = value
        expect(img.endian).to eq(value)
      end
    end
  end

  describe '#using_filter_does_not_cause_endless_loop' do
    it 'works' do
      img = Magick::Image.new(1, 1)
      Magick::FilterType.values do |value|
        img.filter = value
        expect(img.filter).to eq(value)
      end
    end
  end

  describe '#using_gravity_type_does_not_cause_endless_loop' do
    it 'works' do
      img = Magick::Image.new(1, 1)
      Magick::GravityType.values do |value|
        img.gravity = value
        expect(img.gravity).to eq(value)
      end
    end
  end

  describe '#using_image_type_does_not_cause_endless_loop' do
    it 'works' do
      info = Magick::Image::Info.new
      Magick::ImageType.values do |value|
        info.image_type = value
        expect(info.image_type).to eq(value)
      end
    end
  end

  describe '#using_orientation_type_does_not_cause_endless_loop' do
    it 'works' do
      info = Magick::Image::Info.new
      Magick::OrientationType.values do |value|
        info.orientation = value
        expect(info.orientation).to eq(value)
      end
    end
  end

  describe '#using_interlace_type_does_not_cause_endless_loop' do
    it 'works' do
      info = Magick::Image::Info.new
      Magick::InterlaceType.values do |value|
        info.interlace = value
        expect(info.interlace).to eq(value)
      end
    end
  end

  describe '#using_pixel_interpolation_method_does_not_cause_endless_loop' do
    it 'works' do
      img = Magick::Image.new(1, 1)
      Magick::PixelInterpolateMethod.values do |value|
        img.pixel_interpolation_method = value
        expect(img.pixel_interpolation_method).to eq(value)
      end
    end
  end

  describe '#using_rendering_intent_does_not_cause_endless_loop' do
    it 'works' do
      img = Magick::Image.new(1, 1)
      Magick::RenderingIntent.values do |value|
        img.rendering_intent = value
        expect(img.rendering_intent).to eq(value)
      end
    end
  end

  describe '#using_resolution_type_does_not_cause_endless_loop' do
    it 'works' do
      info = Magick::Image::Info.new
      Magick::ResolutionType.values do |value|
        info.units = value
        expect(info.units).to eq(value)
      end
    end
  end

  describe '#using_virtual_pixel_method_does_not_cause_endless_loop' do
    it 'works' do
      img = Magick::Image.new(1, 1)
      Magick::VirtualPixelMethod.values do |value|
        img.virtual_pixel_method = value
        expect(img.virtual_pixel_method).to eq(value)
      end
    end
  end

  describe '#storage_type_name' do
    it 'works' do
      img = Magick::Image.new(20, 20)
      pixels = img.export_pixels(0, 0, 20, 20, 'RGB').pack('D*')

      expect do
        img.import_pixels(0, 0, 20, 20, 'RGB', pixels, Magick::UndefinedPixel)
      end.to raise_error(ArgumentError, /UndefinedPixel/)
    end
  end

  describe '#stretch_type_name' do
    it 'works' do
      Magick::StretchType.values do |stretch|
        font = Magick::Font.new('Arial', 'font test', 'Arial family', Magick::NormalStyle, stretch, 400, nil, 'test foundry', 'test format')
        expect(font.to_s).to match(/stretch=#{stretch.to_s}/)
      end

      font = Magick::Font.new('Arial', 'font test', 'Arial family', Magick::NormalStyle, nil, 400, nil, 'test foundry', 'test format')
      expect(font.to_s).to match(/stretch=UndefinedStretch/)
    end
  end

  describe '#style_type_name' do
    it 'works' do
      Magick::StyleType.values do |style|
        font = Magick::Font.new('Arial', 'font test', 'Arial family', style, Magick::NormalStretch, 400, nil, 'test foundry', 'test format')
        expect(font.to_s).to match(/style=#{style.to_s}/)
      end

      font = Magick::Font.new('Arial', 'font test', 'Arial family', nil, Magick::NormalStretch, 400, nil, 'test foundry', 'test format')
      expect(font.to_s).to match(/style=UndefinedStyle/)
    end
  end
end
