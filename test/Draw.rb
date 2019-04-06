#!/usr/bin/env ruby -w

require 'rmagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner' unless RUBY_VERSION[/^1\.9|^2/]

class DrawUT < Test::Unit::TestCase
  def setup
    @draw = Magick::Draw.new
  end

  def test_affine
    assert_nothing_raised do
      @draw.affine = Magick::AffineMatrix.new(1, 2, 3, 4, 5, 6)
    end
    assert_raise(TypeError) { @draw.affine = [1, 2, 3, 4, 5, 6] }
  end

  def test_align
    assert_nothing_raised { @draw.align = Magick::UndefinedAlign }
    assert_nothing_raised { @draw.align = Magick::LeftAlign }
    assert_nothing_raised { @draw.align = Magick::CenterAlign }
    assert_nothing_raised { @draw.align = Magick::RightAlign }
  end

  def test_decorate
    assert_nothing_raised { @draw.decorate = Magick::NoDecoration }
    assert_nothing_raised { @draw.decorate = Magick::UnderlineDecoration }
    assert_nothing_raised { @draw.decorate = Magick::OverlineDecoration }
    assert_nothing_raised { @draw.decorate = Magick::LineThroughDecoration }
  end

  def test_density
    assert_nothing_raised { @draw.density = '90x90' }
    assert_nothing_raised { @draw.density = 'x90' }
    assert_nothing_raised { @draw.density = '90' }
    assert_raise(TypeError) { @draw.density = 2 }
  end

  def test_encoding
    assert_nothing_raised { @draw.encoding = 'AdobeCustom' }
    assert_raise(TypeError) { @draw.encoding = 2 }
  end

  def test_fill
    assert_nothing_raised { @draw.fill = 'white' }
    assert_nothing_raised { @draw.fill = Magick::Pixel.from_color('white') }
    assert_raise(TypeError) { @draw.fill = 2 }
  end

  def test_fill_pattern
    assert_nothing_raised { @draw.fill_pattern = nil }
    assert_nothing_raised do
      img1 = Magick::Image.new(10, 10)
      img2 = Magick::Image.new(20, 20)

      @draw.fill_pattern = img1
      @draw.fill_pattern = img2
    end

    assert_raise(NoMethodError) { @draw.fill_pattern = 'x' }
  end

  def test_font
    assert_nothing_raised { @draw.font = 'Arial-Bold' }
    assert_raise(TypeError) { @draw.font = 2 }
  end

  def test_font_family
    assert_nothing_raised { @draw.font_family = 'Arial' }
    assert_raise(TypeError) { @draw.font_family = 2 }
  end

  def test_font_stretch
    assert_nothing_raised { @draw.font_stretch = Magick::NormalStretch }
    assert_nothing_raised { @draw.font_stretch = Magick::UltraCondensedStretch }
    assert_nothing_raised { @draw.font_stretch = Magick::ExtraCondensedStretch }
    assert_nothing_raised { @draw.font_stretch = Magick::CondensedStretch }
    assert_nothing_raised { @draw.font_stretch = Magick::SemiCondensedStretch }
    assert_nothing_raised { @draw.font_stretch = Magick::SemiExpandedStretch }
    assert_nothing_raised { @draw.font_stretch = Magick::ExpandedStretch }
    assert_nothing_raised { @draw.font_stretch = Magick::ExtraExpandedStretch }
    assert_nothing_raised { @draw.font_stretch = Magick::UltraExpandedStretch }
    assert_nothing_raised { @draw.font_stretch = Magick::AnyStretch }

    assert_raise(TypeError) { @draw.font_stretch = 2 }
  end

  def test_font_style
    assert_nothing_raised { @draw.font_style = Magick::NormalStyle }
    assert_nothing_raised { @draw.font_style = Magick::ItalicStyle }
    assert_nothing_raised { @draw.font_style = Magick::ObliqueStyle }
    assert_nothing_raised { @draw.font_style = Magick::AnyStyle }

    assert_raise(TypeError) { @draw.font_style = 2 }
  end

  def test_font_weight
    assert_nothing_raised { @draw.font_weight = Magick::AnyWeight }
    assert_nothing_raised { @draw.font_weight = Magick::NormalWeight }
    assert_nothing_raised { @draw.font_weight = Magick::BoldWeight }
    assert_nothing_raised { @draw.font_weight = Magick::BolderWeight }
    assert_nothing_raised { @draw.font_weight = Magick::LighterWeight }
    assert_nothing_raised { @draw.font_weight = 200 }

    assert_raise(ArgumentError) { @draw.font_weight = 99 }
    assert_raise(ArgumentError) { @draw.font_weight = 901 }
  end

  def test_gravity
    assert_nothing_raised { @draw.gravity = Magick::UndefinedGravity }
    assert_nothing_raised { @draw.gravity = Magick::ForgetGravity }
    assert_nothing_raised { @draw.gravity = Magick::NorthWestGravity }
    assert_nothing_raised { @draw.gravity = Magick::NorthGravity }
    assert_nothing_raised { @draw.gravity = Magick::NorthEastGravity }
    assert_nothing_raised { @draw.gravity = Magick::WestGravity }
    assert_nothing_raised { @draw.gravity = Magick::CenterGravity }
    assert_nothing_raised { @draw.gravity = Magick::EastGravity }
    assert_nothing_raised { @draw.gravity = Magick::SouthWestGravity }
    assert_nothing_raised { @draw.gravity = Magick::SouthGravity }
    assert_nothing_raised { @draw.gravity = Magick::SouthEastGravity }
    assert_nothing_raised { @draw.gravity = Magick::StaticGravity }

    assert_raise(TypeError) { @draw.gravity = 2 }
  end

  def test_interline_spacing
    assert_nothing_raised { @draw.interline_spacing = 2 }
    assert_raise(TypeError) { @draw.interline_spacing = 'x' }
  end

  def test_interword_spacing
    assert_nothing_raised { @draw.interword_spacing = 2 }
    assert_raise(TypeError) { @draw.interword_spacing = 'x' }
  end

  def test_kerning
    assert_nothing_raised { @draw.kerning = 2 }
    assert_raise(TypeError) { @draw.kerning = 'x' }
  end

  def test_pointsize
    assert_nothing_raised { @draw.pointsize = 2 }
    assert_raise(TypeError) { @draw.pointsize = 'x' }
  end

  def test_rotation
    assert_nothing_raised { @draw.rotation = 15 }
    assert_raise(TypeError) { @draw.rotation = 'x' }
  end

  def test_stroke
    assert_nothing_raised { @draw.stroke = Magick::Pixel.from_color('white') }
    assert_nothing_raised { @draw.stroke = 'white' }
    assert_raise(TypeError) { @draw.stroke = 2 }
  end

  def test_stroke_pattern
    assert_nothing_raised { @draw.stroke_pattern = nil }
    assert_nothing_raised do
      img1 = Magick::Image.new(10, 10)
      img2 = Magick::Image.new(20, 20)

      @draw.stroke_pattern = img1
      @draw.stroke_pattern = img2
    end

    assert_raise(NoMethodError) { @draw.stroke_pattern = 'x' }
  end

  def test_stroke_width
    assert_nothing_raised { @draw.stroke_width = 15 }
    assert_raise(TypeError) { @draw.stroke_width = 'x' }
  end

  def test_text_antialias
    assert_nothing_raised { @draw.text_antialias = true }
    assert_nothing_raised { @draw.text_antialias = false }
  end

  def test_tile
    assert_nothing_raised { @draw.tile = nil }
    assert_nothing_raised do
      img1 = Magick::Image.new(10, 10)
      img2 = Magick::Image.new(20, 20)

      @draw.tile = img1
      @draw.tile = img2
    end
  end

  def test_undercolor
    assert_nothing_raised { @draw.undercolor = Magick::Pixel.from_color('white') }
    assert_nothing_raised { @draw.undercolor = 'white' }
    assert_raise(TypeError) { @draw.undercolor = 2 }
  end

  def test_annotate
    assert_nothing_raised do
      img = Magick::Image.new(10, 10)
      @draw.annotate(img, 0, 0, 0, 20, 'Hello world')

      yield_obj = nil
      @draw.annotate(img, 100, 100, 20, 20, 'Hello world 2') do |draw|
        yield_obj = draw
      end
      assert_instance_of(Magick::Draw, yield_obj)
    end

    assert_raise(TypeError) do
      img = Magick::Image.new(10, 10)
      @draw.annotate(img, 0, 0, 0, 20, nil)
    end

    assert_raise(NoMethodError) { @draw.annotate('x', 0, 0, 0, 20, 'Hello world') }
  end

  def test_dup
    @draw.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    @draw.taint
    @draw.freeze
    dup = @draw.dup
    assert_instance_of(Magick::Draw, dup)
  end

  def test_clone
    @draw.taint
    @draw.freeze
    clone = @draw.clone
    assert_instance_of(Magick::Draw, clone)
  end

  def test_composite
    composite_operators = [
      Magick::AddCompositeOp,
      Magick::AtopCompositeOp,
      Magick::BlendCompositeOp,
      Magick::BlurCompositeOp,
      Magick::BumpmapCompositeOp,
      Magick::ChangeMaskCompositeOp,
      Magick::ClearCompositeOp,
      Magick::ColorBurnCompositeOp,
      Magick::ColorDodgeCompositeOp,
      Magick::ColorizeCompositeOp,
      Magick::CopyBlackCompositeOp,
      Magick::CopyBlueCompositeOp,
      Magick::CopyCompositeOp,
      Magick::CopyCyanCompositeOp,
      Magick::CopyGreenCompositeOp,
      Magick::CopyMagentaCompositeOp,
      Magick::CopyOpacityCompositeOp,
      Magick::CopyRedCompositeOp,
      Magick::CopyYellowCompositeOp,
      Magick::DarkenCompositeOp,
      Magick::DarkenIntensityCompositeOp,
      Magick::DistortCompositeOp,
      Magick::DivideCompositeOp,
      Magick::DivideSrcCompositeOp,
      Magick::DstAtopCompositeOp,
      Magick::DstCompositeOp,
      Magick::DstInCompositeOp,
      Magick::DstOutCompositeOp,
      Magick::DstOverCompositeOp,
      Magick::DifferenceCompositeOp,
      Magick::DisplaceCompositeOp,
      Magick::DissolveCompositeOp,
      Magick::ExclusionCompositeOp,
      Magick::HardLightCompositeOp,
      Magick::HueCompositeOp,
      Magick::InCompositeOp,
      Magick::LightenCompositeOp,
      Magick::LightenIntensityCompositeOp,
      Magick::LinearBurnCompositeOp,
      Magick::LinearDodgeCompositeOp,
      Magick::LinearLightCompositeOp,
      Magick::LuminizeCompositeOp,
      Magick::MathematicsCompositeOp,
      Magick::MinusCompositeOp,
      Magick::MinusSrcCompositeOp,
      Magick::ModulateCompositeOp,
      Magick::MultiplyCompositeOp,
      Magick::NoCompositeOp,
      Magick::OutCompositeOp,
      Magick::OverCompositeOp,
      Magick::OverlayCompositeOp,
      Magick::PegtopLightCompositeOp,
      Magick::PinLightCompositeOp,
      Magick::PlusCompositeOp,
      Magick::ReplaceCompositeOp,
      Magick::SaturateCompositeOp,
      Magick::ScreenCompositeOp,
      Magick::SoftLightCompositeOp,
      Magick::SrcAtopCompositeOp,
      Magick::SrcCompositeOp,
      Magick::SrcInCompositeOp,
      Magick::SrcOutCompositeOp,
      Magick::SrcOverCompositeOp,
      Magick::SubtractCompositeOp,
      Magick::ThresholdCompositeOp,
      Magick::UndefinedCompositeOp,
      Magick::VividLightCompositeOp,
      Magick::XorCompositeOp
    ]
    composite_operators << Magick::HardMixCompositeOp if Gem::Version.new('6.8.9') <= Gem::Version.new(IM_VERSION)

    img = Magick::Image.new(10, 10)
    assert_nothing_raised { @draw.composite(0, 0, 10, 10, img) }

    composite_operators.each do |op|
      assert_nothing_raised { @draw.composite(0, 0, 10, 10, img, op) }
    end

    assert_raise(TypeError) { @draw.composite('x', 0, 10, 10, img) }
    assert_raise(TypeError) { @draw.composite(0, 'y', 10, 10, img) }
    assert_raise(TypeError) { @draw.composite(0, 0, 'w', 10, img) }
    assert_raise(TypeError) { @draw.composite(0, 0, 10, 'h', img) }
    assert_raise(TypeError) { @draw.composite(0, 0, 10, 10, img, Magick::CenterAlign) }
    assert_raise(NoMethodError) { @draw.composite(0, 0, 10, 10, 'image') }
    assert_raise(ArgumentError) { @draw.composite(0, 0, 10, 10) }
    assert_raise(ArgumentError) { @draw.composite(0, 0, 10, 10, img, Magick::AddCompositeOp, 'x') }
  end

  def test_draw
    draw = @draw.dup

    img = Magick::Image.new(10, 10)
    @draw.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    assert_nothing_raised { @draw.draw(img) }

    assert_raise(ArgumentError) { draw.draw(img) }
    assert_raise(NoMethodError) { draw.draw('x') }
  end

  def test_get_type_metrics
    img = Magick::Image.new(10, 10)
    assert_nothing_raised { @draw.get_type_metrics('ABCDEF') }
    assert_nothing_raised { @draw.get_type_metrics(img, 'ABCDEF') }

    assert_raise(ArgumentError) { @draw.get_type_metrics }
    assert_raise(ArgumentError) { @draw.get_type_metrics(img, 'ABCDEF', 20) }
    assert_raise(ArgumentError) { @draw.get_type_metrics(img, '') }
    assert_raise(NoMethodError) { @draw.get_type_metrics('x', 'ABCDEF') }
  end

  def test_get_multiline_type_metrics
    img = Magick::Image.new(10, 10)
    assert_nothing_raised { @draw.get_multiline_type_metrics('ABCDEF') }
    assert_nothing_raised { @draw.get_multiline_type_metrics(img, 'ABCDEF') }

    assert_raise(ArgumentError) { @draw.get_multiline_type_metrics }
    assert_raise(ArgumentError) { @draw.get_multiline_type_metrics(img, 'ABCDEF', 20) }
    assert_raise(ArgumentError) { @draw.get_multiline_type_metrics(img, '') }
  end

  def test_inspect
    assert_equal('(no primitives defined)', @draw.inspect)

    @draw.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    @draw.fill('yellow')
    assert_equal("path 'M110,100 h-75 a75,75 0 1,0 75,-75 z'\nfill \"yellow\"", @draw.inspect)
  end

  def test_marshal
    draw = @draw.dup
    draw.affine = Magick::AffineMatrix.new(1, 2, 3, 4, 5, 6)
    draw.decorate = Magick::LineThroughDecoration
    draw.encoding = 'AdobeCustom'
    draw.gravity = Magick::CenterGravity
    draw.fill = Magick::Pixel.from_color('red')
    draw.fill_pattern = Magick::Image.new(10, 10) { self.format = 'miff' }
    draw.stroke = Magick::Pixel.from_color('blue')
    draw.stroke_width = 5
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
    assert_nothing_raised { dumped = draw.marshal_dump }

    draw2 = @draw.dup
    assert_nothing_raised do
      draw2.marshal_load(dumped)
    end
    assert_equal(draw.inspect, draw2.inspect)
  end

  def test_primitive
    assert_nothing_raised { @draw.primitive('ABCDEF') }
    assert_nothing_raised { @draw.primitive('12345') }
    assert_raise(TypeError) { @draw.primitive(nil) }
  end

  def test_draw_options
    assert_nothing_raised do
      yield_obj = nil

      Magick::Draw.new do |option|
        yield_obj = option
      end
      assert_instance_of(Magick::Image::DrawOptions, yield_obj)
    end
  end
end
