require 'rmagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner'

class LibDrawUT < Test::Unit::TestCase
  def setup
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  def test_affine
    @draw.affine(10.5, 12, 15, 20, 22, 25)
    assert_equal('affine 10.5,12,15,20,22,25', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.affine('x', 12, 15, 20, 22, 25) }
    assert_raise(ArgumentError) { @draw.affine(10, 'x', 15, 20, 22, 25) }
    assert_raise(ArgumentError) { @draw.affine(10, 12, 'x', 20, 22, 25) }
    assert_raise(ArgumentError) { @draw.affine(10, 12, 15, 'x', 22, 25) }
    assert_raise(ArgumentError) { @draw.affine(10, 12, 15, 20, 'x', 25) }
    assert_raise(ArgumentError) { @draw.affine(10, 12, 15, 20, 22, 'x') }
  end

  def test_alpha
    Magick::PaintMethod.values do |method|
      draw = Magick::Draw.new
      draw.alpha(10, '20.5', method)
      assert_nothing_raised { draw.draw(@img) }
    end

    assert_raise(ArgumentError) { @draw.alpha(10, '20.5', 'xxx') }
    assert_raise(ArgumentError) { @draw.alpha('x', 10, Magick::PointMethod) }
    assert_raise(ArgumentError) { @draw.alpha(10, 'x', Magick::PointMethod) }
  end

  def test_arc
    @draw.arc(100.5, 120.5, 200, 250, 20, 370)
    assert_equal('arc 100.5,120.5 200,250 20,370', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.arc('x', 120.5, 200, 250, 20, 370) }
    assert_raise(ArgumentError) { @draw.arc(100.5, 'x', 200, 250, 20, 370) }
    assert_raise(ArgumentError) { @draw.arc(100.5, 120.5, 'x', 250, 20, 370) }
    assert_raise(ArgumentError) { @draw.arc(100.5, 120.5, 200, 'x', 20, 370) }
    assert_raise(ArgumentError) { @draw.arc(100.5, 120.5, 200, 250, 'x', 370) }
    assert_raise(ArgumentError) { @draw.arc(100.5, 120.5, 200, 250, 20, 'x') }
  end

  def test_bezier
    @draw.bezier(10, '20', '20.5', 30, 40.5, 50)
    assert_equal('bezier 10,20,20.5,30,40.5,50', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.bezier }
    assert_raise(ArgumentError) { @draw.bezier(1) }
    assert_raise(ArgumentError) { @draw.bezier('x', 20, 30, 40.5) }
  end

  def test_circle
    @draw.circle(10, '20.5', 30, 40.5)
    assert_equal('circle 10,20.5 30,40.5', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.circle('x', 20, 30, 40) }
    assert_raise(ArgumentError) { @draw.circle(10, 'x', 30, 40) }
    assert_raise(ArgumentError) { @draw.circle(10, 20, 'x', 40) }
    assert_raise(ArgumentError) { @draw.circle(10, 20, 30, 'x') }
  end

  def test_clip_path
    @draw.clip_path('test')
    assert_equal('clip-path test', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }
  end

  def test_clip_rule
    draw = Magick::Draw.new
    draw.clip_rule('evenodd')
    assert_equal('clip-rule evenodd', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.clip_rule('nonzero')
    assert_equal('clip-rule nonzero', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.clip_rule('foo') }
  end

  def test_clip_units
    draw = Magick::Draw.new
    draw.clip_units('userspace')
    assert_equal('clip-units userspace', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.clip_units('userspaceonuse')
    assert_equal('clip-units userspaceonuse', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.clip_units('objectboundingbox')
    assert_equal('clip-units objectboundingbox', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.clip_units('foo') }
  end

  def test_color
    draw = Magick::Draw.new
    draw.color(50.5, 50, Magick::PointMethod)
    assert_equal('color 50.5,50,point', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.color(50.5, 50, Magick::ReplaceMethod)
    assert_equal('color 50.5,50,replace', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.color(50.5, 50, Magick::FloodfillMethod)
    assert_equal('color 50.5,50,floodfill', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.color(50.5, 50, Magick::FillToBorderMethod)
    assert_equal('color 50.5,50,filltoborder', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.color(50.5, 50, Magick::ResetMethod)
    assert_equal('color 50.5,50,reset', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.color(10, 20, 'unknown') }
    assert_raise(ArgumentError) { @draw.color('x', 20, Magick::PointMethod) }
    assert_raise(ArgumentError) { @draw.color(10, 'x', Magick::PointMethod) }
  end

  def test_decorate
    draw = Magick::Draw.new
    draw.decorate(Magick::NoDecoration)
    assert_equal('decorate none', draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.decorate(Magick::UnderlineDecoration)
    assert_equal('decorate underline', draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.decorate(Magick::OverlineDecoration)
    assert_equal('decorate overline', draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.decorate(Magick::OverlineDecoration)
    assert_equal('decorate overline', draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    # draw = Magick::Draw.new
    # draw.decorate('tomato')
    # assert_equal('decorate "tomato"', draw.inspect)
    # draw.text(50, 50, 'Hello world')
    # assert_nothing_raised { draw.draw(@img) }
  end

  def test_define_clip_path
    assert_nothing_raised { @draw.define_clip_path('test') { @draw } }
    assert_equal("push defs\npush clip-path \"test\"\npush graphic-context\npop graphic-context\npop clip-path\npop defs", @draw.inspect)
  end

  def test_ellipse
    @draw.ellipse(50.5, 30, 25, 25, 60, 120)
    assert_equal('ellipse 50.5,30 25,25 60,120', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.ellipse('x', 20, 30, 40, 50, 60) }
    assert_raise(ArgumentError) { @draw.ellipse(10, 'x', 30, 40, 50, 60) }
    assert_raise(ArgumentError) { @draw.ellipse(10, 20, 'x', 40, 50, 60) }
    assert_raise(ArgumentError) { @draw.ellipse(10, 20, 30, 'x', 50, 60) }
    assert_raise(ArgumentError) { @draw.ellipse(10, 20, 30, 40, 'x', 60) }
    assert_raise(ArgumentError) { @draw.ellipse(10, 20, 30, 40, 50, 'x') }
  end

  def test_encoding
    @draw.encoding('UTF-8')
    assert_equal('encoding UTF-8', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }
  end

  def test_fill
    draw = Magick::Draw.new
    draw.fill('tomato')
    assert_equal('fill "tomato"', draw.inspect)
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.fill_color('tomato')
    assert_equal('fill "tomato"', draw.inspect)
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.fill_pattern('tomato')
    assert_equal('fill "tomato"', draw.inspect)
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }

    # draw = Magick::Draw.new
    # draw.fill_pattern('foo')
    # assert_nothing_raised { draw.draw(@img) }
  end

  def test_fill_opacity
    draw = Magick::Draw.new
    draw.fill_opacity(0.5)
    assert_equal('fill-opacity 0.5', draw.inspect)
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.fill_opacity('50%')
    assert_equal('fill-opacity 50%', draw.inspect)
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }

    assert_nothing_raised { @draw.fill_opacity(0.0) }
    assert_nothing_raised { @draw.fill_opacity(1.0) }
    assert_nothing_raised { @draw.fill_opacity('0.0') }
    assert_nothing_raised { @draw.fill_opacity('1.0') }
    assert_nothing_raised { @draw.fill_opacity('20%') }

    assert_raise(ArgumentError) { @draw.fill_opacity(-0.01) }
    assert_raise(ArgumentError) { @draw.fill_opacity(1.01) }
    assert_raise(ArgumentError) { @draw.fill_opacity('-0.01') }
    assert_raise(ArgumentError) { @draw.fill_opacity('1.01') }
    assert_raise(ArgumentError) { @draw.fill_opacity('xxx') }
  end

  def test_fill_rule
    draw = Magick::Draw.new
    draw.fill_rule('evenodd')
    assert_equal('fill-rule evenodd', draw.inspect)
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.fill_rule('nonzero')
    assert_equal('fill-rule nonzero', draw.inspect)
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.fill_rule('zero') }
  end

  def test_font
    draw = Magick::Draw.new
    draw.font('Arial')
    assert_equal("font 'Arial'", draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }
  end

  def test_font_family
    draw = Magick::Draw.new
    draw.font_family('sans-serif')
    assert_equal("font-family 'sans-serif'", draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }
  end

  def test_font_stretch
    Magick::StretchType.values do |stretch|
      next if stretch == Magick::AnyStretch

      draw = Magick::Draw.new
      draw.font_stretch(stretch)
      draw.text(50, 50, 'Hello world')
      assert_nothing_raised { draw.draw(@img) }
    end

    assert_raise(ArgumentError) { @draw.font_stretch('xxx') }
  end

  def test_font_style
    draw = Magick::Draw.new
    draw.font_style(Magick::NormalStyle)
    assert_equal('font-style normal', draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.font_style(Magick::ItalicStyle)
    assert_equal('font-style italic', draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.font_style(Magick::ObliqueStyle)
    assert_equal('font-style oblique', draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.font_style('xxx') }
  end

  def test_font_weight
    Magick::WeightType.values do |weight|
      draw = Magick::Draw.new
      draw.font_weight(weight)
      draw.text(50, 50, 'Hello world')
      assert_nothing_raised { draw.draw(@img) }
    end

    draw = Magick::Draw.new
    draw.font_weight(400)
    assert_equal('font-weight 400', draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.font_weight('xxx') }
  end

  def test_gravity
    Magick::GravityType.values do |gravity|
      next if [Magick::UndefinedGravity].include?(gravity)

      draw = Magick::Draw.new
      draw.gravity(gravity)
      draw.circle(10, '20.5', 30, 40.5)
      assert_nothing_raised { draw.draw(@img) }
    end

    assert_raise(ArgumentError) { @draw.gravity('xxx') }
  end

  def test_image
    Magick::CompositeOperator.values do |composite|
      next if [Magick::CopyAlphaCompositeOp, Magick::NoCompositeOp].include?(composite)

      draw = Magick::Draw.new
      draw.image(composite, 10, 10, 200, 100, "#{IMAGES_DIR}/Flower_Hat.jpg")
      assert_nothing_raised { draw.draw(@img) }
    end

    assert_raise(ArgumentError) { @draw.image('xxx', 10, 10, 200, 100, "#{IMAGES_DIR}/Flower_Hat.jpg") }
    assert_raise(ArgumentError) { @draw.image(Magick::AtopCompositeOp, 'x', 100, 200, 100, "#{IMAGES_DIR}/Flower_Hat.jpg") }
    assert_raise(ArgumentError) { @draw.image(Magick::AtopCompositeOp, 100, 'x', 200, 100, "#{IMAGES_DIR}/Flower_Hat.jpg") }
    assert_raise(ArgumentError) { @draw.image(Magick::AtopCompositeOp, 100, 100, 'x', 100, "#{IMAGES_DIR}/Flower_Hat.jpg") }
    assert_raise(ArgumentError) { @draw.image(Magick::AtopCompositeOp, 100, 100, 200, 'x', "#{IMAGES_DIR}/Flower_Hat.jpg") }
  end

  def test_interline_spacing
    draw = Magick::Draw.new
    draw.interline_spacing(40.5)
    assert_equal('interline-spacing 40.5', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.interline_spacing('40.5')
    assert_equal('interline-spacing 40.5', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    # assert_raise(ArgumentError) { @draw.interline_spacing(Float::NAN) }
    assert_raise(ArgumentError) { @draw.interline_spacing('nan') }
    assert_raise(ArgumentError) { @draw.interline_spacing('xxx') }
    assert_raise(TypeError) { @draw.interline_spacing(nil) }
  end

  def test_interword_spacing
    draw = Magick::Draw.new
    draw.interword_spacing(40.5)
    assert_equal('interword-spacing 40.5', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.interword_spacing('40.5')
    assert_equal('interword-spacing 40.5', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    # assert_raise(ArgumentError) { @draw.interword_spacing(Float::NAN) }
    assert_raise(ArgumentError) { @draw.interword_spacing('nan') }
    assert_raise(ArgumentError) { @draw.interword_spacing('xxx') }
    assert_raise(TypeError) { @draw.interword_spacing(nil) }
  end

  def test_kerning
    draw = Magick::Draw.new
    draw.kerning(40.5)
    assert_equal('kerning 40.5', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.kerning('40.5')
    assert_equal('kerning 40.5', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    # assert_raise(ArgumentError) { @draw.kerning(Float::NAN) }
    assert_raise(ArgumentError) { @draw.kerning('nan') }
    assert_raise(ArgumentError) { @draw.kerning('xxx') }
    assert_raise(TypeError) { @draw.kerning(nil) }
  end

  def test_line
    @draw.line(10, '20.5', 30, 40.5)
    assert_equal('line 10,20.5 30,40.5', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.line('x', '20.5', 30, 40.5) }
    assert_raise(ArgumentError) { @draw.line(10, 'x', 30, 40.5) }
    assert_raise(ArgumentError) { @draw.line(10, '20.5', 'x', 40.5) }
    assert_raise(ArgumentError) { @draw.line(10, '20.5', 30, 'x') }
  end

  def test_opacity
    @draw.opacity(0.8)
    assert_equal('opacity 0.8', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_nothing_raised { @draw.opacity(0.0) }
    assert_nothing_raised { @draw.opacity(1.0) }
    assert_nothing_raised { @draw.opacity('0.0') }
    assert_nothing_raised { @draw.opacity('1.0') }
    assert_nothing_raised { @draw.opacity('20%') }

    assert_raise(ArgumentError) { @draw.opacity(-0.01) }
    assert_raise(ArgumentError) { @draw.opacity(1.01) }
    assert_raise(ArgumentError) { @draw.opacity('-0.01') }
    assert_raise(ArgumentError) { @draw.opacity('1.01') }
    assert_raise(ArgumentError) { @draw.opacity('xxx') }
  end

  def test_path
    @draw.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    assert_equal("path 'M110,100 h-75 a75,75 0 1,0 75,-75 z'", @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }
  end

  def test_pattern
    @draw.pattern('hat', 0, 10.5, 20, '20') {}
    assert_equal("push defs\npush pattern hat 0 10.5 20 20\npush graphic-context\npop graphic-context\npop pattern\npop defs", @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.pattern('hat', 'x', 0, 20, 20) {} }
    assert_raise(ArgumentError) { @draw.pattern('hat', 0, 'x', 20, 20) {} }
    assert_raise(ArgumentError) { @draw.pattern('hat', 0, 0, 'x', 20) {} }
    assert_raise(ArgumentError) { @draw.pattern('hat', 0, 0, 20, 'x') {} }
  end

  def test_point
    @draw.point(10.5, '20')
    assert_equal('point 10.5,20', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.point('x', 20) }
    assert_raise(ArgumentError) { @draw.point(10, 'x') }
  end

  def test_pointsize
    @draw.pointsize(20.5)
    assert_equal('font-size 20.5', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.pointsize('x') }
  end

  def test_font_size
    @draw.font_size(20)
    assert_equal('font-size 20', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.font_size('x') }
  end

  def test_polygon
    @draw.polygon(0, '0.5', 8.5, 16, 16, 0, 0, 0)
    assert_equal('polygon 0,0.5,8.5,16,16,0,0,0', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.polygon }
    assert_raise(ArgumentError) { @draw.polygon(0) }
    assert_raise(ArgumentError) { @draw.polygon('x', 0, 8, 16, 16, 0, 0, 0) }
  end

  def test_polyline
    @draw.polyline(0, '0.5', 16.5, 16)
    assert_equal('polyline 0,0.5,16.5,16', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.polyline }
    assert_raise(ArgumentError) { @draw.polyline(0) }
    assert_raise(ArgumentError) { @draw.polyline('x', 0, 16, 16) }
  end

  def test_rectangle
    @draw.rectangle(10, '10', 100, 100)
    assert_equal('rectangle 10,10 100,100', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.rectangle('x', 10, 20, 20) }
    assert_raise(ArgumentError) { @draw.rectangle(10, 'x', 20, 20) }
    assert_raise(ArgumentError) { @draw.rectangle(10, 10, 'x', 20) }
    assert_raise(ArgumentError) { @draw.rectangle(10, 10, 20, 'x') }
  end

  def test_rotate
    @draw.rotate(45)
    assert_equal('rotate 45', @draw.inspect)
    @draw.text(50, 50, 'Hello world')
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.rotate('x') }
  end

  def test_roundrectangle
    @draw.roundrectangle(10, '10', 100, 100, 20, 20)
    assert_equal('roundrectangle 10,10,100,100,20,20', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.roundrectangle('x', '10', 100, 100, 20, 20) }
    assert_raise(ArgumentError) { @draw.roundrectangle(10, 'x', 100, 100, 20, 20) }
    assert_raise(ArgumentError) { @draw.roundrectangle(10, '10', 'x', 100, 20, 20) }
    assert_raise(ArgumentError) { @draw.roundrectangle(10, '10', 100, 'x', 20, 20) }
    assert_raise(ArgumentError) { @draw.roundrectangle(10, '10', 100, 100, 'x', 20) }
    assert_raise(ArgumentError) { @draw.roundrectangle(10, '10', 100, 100, 20, 'x') }
  end

  def test_scale
    @draw.scale('0.5', 1.5)
    assert_equal('scale 0.5,1.5', @draw.inspect)
    @draw.rectangle(10, '10', 100, 100)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.scale('x', 1.5) }
    assert_raise(ArgumentError) { @draw.scale(0.5, 'x') }
  end

  def test_skewx
    @draw.skewx(45)
    assert_equal('skewX 45', @draw.inspect)
    @draw.text(50, 50, 'Hello world')
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.skewx('x') }
  end

  def test_skewy
    @draw.skewy(45)
    assert_equal('skewY 45', @draw.inspect)
    @draw.text(50, 50, 'Hello world')
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.skewy('x') }
  end

  def test_stroke
    @draw.stroke('red')
    assert_equal('stroke "red"', @draw.inspect)
    @draw.rectangle(10, '10', 100, 100)
    assert_nothing_raised { @draw.draw(@img) }

    # assert_raise(ArgumentError) { @draw.stroke(100) }
  end

  def test_stroke_color
    @draw.stroke_color('red')
    assert_equal('stroke "red"', @draw.inspect)
    @draw.rectangle(10, '10', 100, 100)
    assert_nothing_raised { @draw.draw(@img) }

    # assert_raise(ArgumentError) { @draw.stroke_color(100) }
  end

  def test_stroke_pattern
    @draw.stroke_pattern('red')
    assert_equal('stroke "red"', @draw.inspect)
    @draw.rectangle(10, '10', 100, 100)
    assert_nothing_raised { @draw.draw(@img) }

    # assert_raise(ArgumentError) { @draw.stroke_pattern(100) }
  end

  def test_stroke_antialias
    draw = Magick::Draw.new
    draw.stroke_antialias(true)
    assert_equal('stroke-antialias 1', draw.inspect)
    draw.stroke_pattern('red')
    draw.stroke_width(5)
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.stroke_antialias(false)
    assert_equal('stroke-antialias 0', draw.inspect)
    draw.stroke_pattern('red')
    draw.stroke_width(5)
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }
  end

  def test_stroke_dasharray
    draw = Magick::Draw.new
    draw.stroke_dasharray(2, 2)
    assert_equal('stroke-dasharray 2,2', draw.inspect)
    draw.stroke_pattern('red')
    draw.stroke_width(2)
    draw.rectangle(10, '10', 100, 100)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.stroke_dasharray
    assert_equal('stroke-dasharray none', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.stroke_dasharray(-0.1) }
    assert_raise(ArgumentError) { @draw.stroke_dasharray('x') }
  end

  def test_stroke_dashoffset
    @draw.stroke_dashoffset(10)
    assert_equal('stroke-dashoffset 10', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.stroke_dashoffset('x') }
  end

  def test_stroke_linecap
    draw = Magick::Draw.new
    draw.stroke_linecap('butt')
    assert_equal('stroke-linecap butt', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.stroke_linecap('round')
    assert_equal('stroke-linecap round', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.stroke_linecap('square')
    assert_equal('stroke-linecap square', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.stroke_linecap('foo') }
  end

  def test_stroke_linejoin
    draw = Magick::Draw.new
    draw.stroke_linejoin('round')
    assert_equal('stroke-linejoin round', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.stroke_linejoin('miter')
    assert_equal('stroke-linejoin miter', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.stroke_linejoin('bevel')
    assert_equal('stroke-linejoin bevel', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.stroke_linejoin('foo') }
  end

  def test_stroke_miterlimit
    draw = Magick::Draw.new
    draw.stroke_miterlimit(1.0)
    assert_equal('stroke-miterlimit 1.0', draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.stroke_miterlimit(0.9) }
    assert_raise(ArgumentError) { @draw.stroke_miterlimit('foo') }
  end

  def test_stroke_opacity
    @draw.stroke_opacity(0.8)
    assert_equal('stroke-opacity 0.8', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_nothing_raised { @draw.stroke_opacity(0.0) }
    assert_nothing_raised { @draw.stroke_opacity(1.0) }
    assert_nothing_raised { @draw.stroke_opacity('0.0') }
    assert_nothing_raised { @draw.stroke_opacity('1.0') }
    assert_nothing_raised { @draw.stroke_opacity('20%') }

    assert_raise(ArgumentError) { @draw.stroke_opacity(-0.01) }
    assert_raise(ArgumentError) { @draw.stroke_opacity(1.01) }
    assert_raise(ArgumentError) { @draw.stroke_opacity('-0.01') }
    assert_raise(ArgumentError) { @draw.stroke_opacity('1.01') }
    assert_raise(ArgumentError) { @draw.stroke_opacity('xxx') }
  end

  def test_stroke_width
    @draw.stroke_width(2.5)
    assert_equal('stroke-width 2.5', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.stroke_width('xxx') }
  end

  def test_text
    draw = Magick::Draw.new
    draw.text(50, 50, 'Hello world')
    assert_equal("text 50,50 'Hello world'", draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text(50, 50, "Hello 'world'")
    assert_equal("text 50,50 \"Hello 'world'\"", draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text(50, 50, 'Hello "world"')
    assert_equal("text 50,50 'Hello \"world\"'", draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text(50, 50, "Hello 'world\"")
    assert_equal("text 50,50 {Hello 'world\"}", draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text(50, 50, "Hello {'world\"")
    assert_equal("text 50,50 {Hello {'world\"}", draw.inspect)
    assert_nothing_raised { draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.text(50, 50, '') }
    assert_raise(ArgumentError) { @draw.text('x', 50, 'Hello world') }
    assert_raise(ArgumentError) { @draw.text(50, 'x', 'Hello world') }
  end

  def test_text_align
    draw = Magick::Draw.new
    draw.text_align(Magick::LeftAlign)
    assert_equal('text-align left', draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text_align(Magick::RightAlign)
    assert_equal('text-align right', draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text_align(Magick::CenterAlign)
    assert_equal('text-align center', draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.text_align('x') }
  end

  def test_text_anchor
    draw = Magick::Draw.new
    draw.text_anchor(Magick::StartAnchor)
    assert_equal('text-anchor start', draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text_anchor(Magick::MiddleAnchor)
    assert_equal('text-anchor middle', draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text_anchor(Magick::EndAnchor)
    assert_equal('text-anchor end', draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.text_anchor('x') }
  end

  def test_text_antialias
    draw = Magick::Draw.new
    draw.text_antialias(true)
    assert_equal('text-antialias 1', draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text_antialias(false)
    assert_equal('text-antialias 0', draw.inspect)
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }
  end

  def test_text_undercolor
    @draw.text_undercolor('red')
    assert_equal('text-undercolor "red"', @draw.inspect)
    @draw.text(50, 50, 'Hello world')
    assert_nothing_raised { @draw.draw(@img) }
  end

  def test_translate
    @draw.translate('200', 300)
    assert_equal('translate 200,300', @draw.inspect)
    assert_nothing_raised { @draw.draw(@img) }

    assert_raise(ArgumentError) { @draw.translate('x', 300) }
    assert_raise(ArgumentError) { @draw.translate(200, 'x') }
  end
end
