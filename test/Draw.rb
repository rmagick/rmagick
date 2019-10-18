require 'rmagick'
require 'minitest/autorun'

class DrawUT < Minitest::Test
  def setup
    @draw = Magick::Draw.new
  end

  def test_affine
    expect do
      @draw.affine = Magick::AffineMatrix.new(1, 2, 3, 4, 5, 6)
    end.not_to raise_error
    expect { @draw.affine = [1, 2, 3, 4, 5, 6] }.to raise_error(TypeError)
  end

  def test_align
    Magick::AlignType.values do |align|
      expect { @draw.align = align }.not_to raise_error
    end
  end

  def test_decorate
    Magick::DecorationType.values do |decoration|
      expect { @draw.decorate = decoration }.not_to raise_error
    end
  end

  def test_density
    expect { @draw.density = '90x90' }.not_to raise_error
    expect { @draw.density = 'x90' }.not_to raise_error
    expect { @draw.density = '90' }.not_to raise_error
    expect { @draw.density = 2 }.to raise_error(TypeError)
  end

  def test_encoding
    expect { @draw.encoding = 'AdobeCustom' }.not_to raise_error
    expect { @draw.encoding = 2 }.to raise_error(TypeError)
  end

  def test_fill
    expect { @draw.fill = 'white' }.not_to raise_error
    expect { @draw.fill = Magick::Pixel.from_color('white') }.not_to raise_error
    expect { @draw.fill = 2 }.to raise_error(TypeError)
  end

  def test_fill_pattern
    expect { @draw.fill_pattern = nil }.not_to raise_error
    expect do
      img1 = Magick::Image.new(10, 10)
      img2 = Magick::Image.new(20, 20)

      @draw.fill_pattern = img1
      @draw.fill_pattern = img2
    end.not_to raise_error

    expect { @draw.fill_pattern = 'x' }.to raise_error(NoMethodError)
  end

  def test_font
    expect { @draw.font = 'Arial-Bold' }.not_to raise_error
    expect { @draw.font = 2 }.to raise_error(TypeError)
  end

  def test_font_family
    expect { @draw.font_family = 'Arial' }.not_to raise_error
    expect { @draw.font_family = 2 }.to raise_error(TypeError)
  end

  def test_font_stretch
    Magick::StretchType.values do |stretch|
      expect { @draw.font_stretch = stretch }.not_to raise_error
    end

    expect { @draw.font_stretch = 2 }.to raise_error(TypeError)
  end

  def test_font_style
    Magick::StyleType.values do |style|
      expect { @draw.font_style = style }.not_to raise_error
    end

    expect { @draw.font_style = 2 }.to raise_error(TypeError)
  end

  def test_font_weight
    Magick::WeightType.values do |weight|
      expect { @draw.font_weight = weight }.not_to raise_error
    end

    expect { @draw.font_weight = 99 }.to raise_error(ArgumentError)
    expect { @draw.font_weight = 901 }.to raise_error(ArgumentError)
  end

  def test_gravity
    Magick::GravityType.values do |gravity|
      expect { @draw.gravity = gravity }.not_to raise_error
    end

    expect { @draw.gravity = 2 }.to raise_error(TypeError)
  end

  def test_interline_spacing
    expect { @draw.interline_spacing = 2 }.not_to raise_error
    expect { @draw.interline_spacing = 'x' }.to raise_error(TypeError)
  end

  def test_interword_spacing
    expect { @draw.interword_spacing = 2 }.not_to raise_error
    expect { @draw.interword_spacing = 'x' }.to raise_error(TypeError)
  end

  def test_kerning
    expect { @draw.kerning = 2 }.not_to raise_error
    expect { @draw.kerning = 'x' }.to raise_error(TypeError)
  end

  def test_pointsize
    expect { @draw.pointsize = 2 }.not_to raise_error
    expect { @draw.pointsize = 'x' }.to raise_error(TypeError)
  end

  def test_rotation
    expect { @draw.rotation = 15 }.not_to raise_error
    expect { @draw.rotation = 'x' }.to raise_error(TypeError)
  end

  def test_stroke
    expect { @draw.stroke = Magick::Pixel.from_color('white') }.not_to raise_error
    expect { @draw.stroke = 'white' }.not_to raise_error
    expect { @draw.stroke = 2 }.to raise_error(TypeError)
  end

  def test_stroke_pattern
    expect { @draw.stroke_pattern = nil }.not_to raise_error
    expect do
      img1 = Magick::Image.new(10, 10)
      img2 = Magick::Image.new(20, 20)

      @draw.stroke_pattern = img1
      @draw.stroke_pattern = img2
    end.not_to raise_error

    expect { @draw.stroke_pattern = 'x' }.to raise_error(NoMethodError)
  end

  def test_stroke_width
    expect { @draw.stroke_width = 15 }.not_to raise_error
    expect { @draw.stroke_width = 'x' }.to raise_error(TypeError)
  end

  def test_text_antialias
    expect { @draw.text_antialias = true }.not_to raise_error
    expect { @draw.text_antialias = false }.not_to raise_error
  end

  def test_tile
    expect { @draw.tile = nil }.not_to raise_error
    expect do
      img1 = Magick::Image.new(10, 10)
      img2 = Magick::Image.new(20, 20)

      @draw.tile = img1
      @draw.tile = img2
    end.not_to raise_error
  end

  def test_undercolor
    expect { @draw.undercolor = Magick::Pixel.from_color('white') }.not_to raise_error
    expect { @draw.undercolor = 'white' }.not_to raise_error
    expect { @draw.undercolor = 2 }.to raise_error(TypeError)
  end

  def test_annotate
    expect do
      img = Magick::Image.new(10, 10)
      @draw.annotate(img, 0, 0, 0, 20, 'Hello world')

      yield_obj = nil
      @draw.annotate(img, 100, 100, 20, 20, 'Hello world 2') do |draw|
        yield_obj = draw
      end
      expect(yield_obj).to be_instance_of(Magick::Draw)
    end.not_to raise_error

    expect do
      img = Magick::Image.new(10, 10)
      @draw.annotate(img, 0, 0, 0, 20, nil)
    end.to raise_error(TypeError)

    expect { @draw.annotate('x', 0, 0, 0, 20, 'Hello world') }.to raise_error(NoMethodError)
  end

  def test_annotate_stack_buffer_overflow
    expect do
      if 1.size == 8
        # 64-bit environment can use larger value for Integer and it can causes stack buffer overflow.
        img = Magick::Image.new(10, 10)
        @draw.annotate(img, 2**63, 2**63, 2**62, 2**62, 'Hello world')
      end
    end.not_to raise_error
  end

  def test_dup
    @draw.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    @draw.taint
    @draw.freeze
    dup = @draw.dup
    expect(dup).to be_instance_of(Magick::Draw)
  end

  def test_clone
    @draw.taint
    @draw.freeze
    clone = @draw.clone
    expect(clone).to be_instance_of(Magick::Draw)
  end

  def test_composite
    img = Magick::Image.new(10, 10)
    expect { @draw.composite(0, 0, 10, 10, img) }.not_to raise_error

    Magick::CompositeOperator.values do |op|
      expect { @draw.composite(0, 0, 10, 10, img, op) }.not_to raise_error
    end

    expect { @draw.composite('x', 0, 10, 10, img) }.to raise_error(TypeError)
    expect { @draw.composite(0, 'y', 10, 10, img) }.to raise_error(TypeError)
    expect { @draw.composite(0, 0, 'w', 10, img) }.to raise_error(TypeError)
    expect { @draw.composite(0, 0, 10, 'h', img) }.to raise_error(TypeError)
    expect { @draw.composite(0, 0, 10, 10, img, Magick::CenterAlign) }.to raise_error(TypeError)
    expect { @draw.composite(0, 0, 10, 10, 'image') }.to raise_error(NoMethodError)
    expect { @draw.composite(0, 0, 10, 10) }.to raise_error(ArgumentError)
    expect { @draw.composite(0, 0, 10, 10, img, Magick::ModulusAddCompositeOp, 'x') }.to raise_error(ArgumentError)
  end

  def test_draw
    draw = @draw.dup

    img = Magick::Image.new(10, 10)
    @draw.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    expect { @draw.draw(img) }.not_to raise_error

    expect { draw.draw(img) }.to raise_error(ArgumentError)
    expect { draw.draw('x') }.to raise_error(NoMethodError)
  end

  def test_get_type_metrics
    img = Magick::Image.new(10, 10)
    expect { @draw.get_type_metrics('ABCDEF') }.not_to raise_error
    expect { @draw.get_type_metrics(img, 'ABCDEF') }.not_to raise_error

    expect { @draw.get_type_metrics }.to raise_error(ArgumentError)
    expect { @draw.get_type_metrics(img, 'ABCDEF', 20) }.to raise_error(ArgumentError)
    expect { @draw.get_type_metrics(img, '') }.to raise_error(ArgumentError)
    expect { @draw.get_type_metrics('x', 'ABCDEF') }.to raise_error(NoMethodError)
  end

  def test_get_multiline_type_metrics
    img = Magick::Image.new(10, 10)
    expect { @draw.get_multiline_type_metrics('ABCDEF') }.not_to raise_error
    expect { @draw.get_multiline_type_metrics(img, 'ABCDEF') }.not_to raise_error

    expect { @draw.get_multiline_type_metrics }.to raise_error(ArgumentError)
    expect { @draw.get_multiline_type_metrics(img, 'ABCDEF', 20) }.to raise_error(ArgumentError)
    expect { @draw.get_multiline_type_metrics(img, '') }.to raise_error(ArgumentError)
  end

  def test_inspect
    expect(@draw.inspect).to eq('(no primitives defined)')

    @draw.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    @draw.fill('yellow')
    expect(@draw.inspect).to eq("path 'M110,100 h-75 a75,75 0 1,0 75,-75 z'\nfill \"yellow\"")
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
    expect { dumped = draw.marshal_dump }.not_to raise_error

    draw2 = @draw.dup
    expect do
      draw2.marshal_load(dumped)
    end.not_to raise_error
    expect(draw2.inspect).to eq(draw.inspect)
  end

  def test_primitive
    expect { @draw.primitive('ABCDEF') }.not_to raise_error
    expect { @draw.primitive('12345') }.not_to raise_error
    expect { @draw.primitive(nil) }.to raise_error(TypeError)
  end

  def test_draw_options
    expect do
      yield_obj = nil

      Magick::Draw.new do |option|
        yield_obj = option
      end
      expect(yield_obj).to be_instance_of(Magick::Image::DrawOptions)
    end.not_to raise_error
  end

  def test_issue_604
    points = [0, 0, 1, 1, 2, 2]

    pr = Magick::Draw.new

    pr.define_clip_path('example') do
      pr.polygon(*points)
    end

    pr.push
    pr.clip_path('example')

    composite = Magick::Image.new(10, 10)
    pr.composite(0, 0, 10, 10, composite)

    pr.pop

    canvas = Magick::Image.new(10, 10)
    pr.draw(canvas)
  end
end
