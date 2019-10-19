require 'rmagick'
require 'minitest/autorun'

class LibDrawUT < Minitest::Test
  def setup
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  def test_affine
    @draw.affine(10.5, 12, 15, 20, 22, 25)
    expect(@draw.inspect).to eq('affine 10.5,12,15,20,22,25')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.affine('x', 12, 15, 20, 22, 25) }.to raise_error(ArgumentError)
    expect { @draw.affine(10, 'x', 15, 20, 22, 25) }.to raise_error(ArgumentError)
    expect { @draw.affine(10, 12, 'x', 20, 22, 25) }.to raise_error(ArgumentError)
    expect { @draw.affine(10, 12, 15, 'x', 22, 25) }.to raise_error(ArgumentError)
    expect { @draw.affine(10, 12, 15, 20, 'x', 25) }.to raise_error(ArgumentError)
    expect { @draw.affine(10, 12, 15, 20, 22, 'x') }.to raise_error(ArgumentError)
  end

  def test_alpha
    Magick::PaintMethod.values do |method|
      draw = Magick::Draw.new
      draw.alpha(10, '20.5', method)
      assert_nothing_raised { draw.draw(@img) }
    end

    expect { @draw.alpha(10, '20.5', 'xxx') }.to raise_error(ArgumentError)
    expect { @draw.alpha('x', 10, Magick::PointMethod) }.to raise_error(ArgumentError)
    expect { @draw.alpha(10, 'x', Magick::PointMethod) }.to raise_error(ArgumentError)
  end

  def test_arc
    @draw.arc(100.5, 120.5, 200, 250, 20, 370)
    expect(@draw.inspect).to eq('arc 100.5,120.5 200,250 20,370')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.arc('x', 120.5, 200, 250, 20, 370) }.to raise_error(ArgumentError)
    expect { @draw.arc(100.5, 'x', 200, 250, 20, 370) }.to raise_error(ArgumentError)
    expect { @draw.arc(100.5, 120.5, 'x', 250, 20, 370) }.to raise_error(ArgumentError)
    expect { @draw.arc(100.5, 120.5, 200, 'x', 20, 370) }.to raise_error(ArgumentError)
    expect { @draw.arc(100.5, 120.5, 200, 250, 'x', 370) }.to raise_error(ArgumentError)
    expect { @draw.arc(100.5, 120.5, 200, 250, 20, 'x') }.to raise_error(ArgumentError)
  end

  def test_bezier
    @draw.bezier(10, '20', '20.5', 30, 40.5, 50)
    expect(@draw.inspect).to eq('bezier 10,20,20.5,30,40.5,50')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.bezier }.to raise_error(ArgumentError)
    expect { @draw.bezier(1) }.to raise_error(ArgumentError)
    expect { @draw.bezier('x', 20, 30, 40.5) }.to raise_error(ArgumentError)
  end

  def test_circle
    @draw.circle(10, '20.5', 30, 40.5)
    expect(@draw.inspect).to eq('circle 10,20.5 30,40.5')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.circle('x', 20, 30, 40) }.to raise_error(ArgumentError)
    expect { @draw.circle(10, 'x', 30, 40) }.to raise_error(ArgumentError)
    expect { @draw.circle(10, 20, 'x', 40) }.to raise_error(ArgumentError)
    expect { @draw.circle(10, 20, 30, 'x') }.to raise_error(ArgumentError)
  end

  def test_clip_path
    @draw.clip_path('test')
    expect(@draw.inspect).to eq('clip-path test')
    assert_nothing_raised { @draw.draw(@img) }
  end

  def test_clip_rule
    draw = Magick::Draw.new
    draw.clip_rule('evenodd')
    expect(draw.inspect).to eq('clip-rule evenodd')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.clip_rule('nonzero')
    expect(draw.inspect).to eq('clip-rule nonzero')
    assert_nothing_raised { draw.draw(@img) }

    expect { @draw.clip_rule('foo') }.to raise_error(ArgumentError)
  end

  def test_clip_units
    draw = Magick::Draw.new
    draw.clip_units('userspace')
    expect(draw.inspect).to eq('clip-units userspace')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.clip_units('userspaceonuse')
    expect(draw.inspect).to eq('clip-units userspaceonuse')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.clip_units('objectboundingbox')
    expect(draw.inspect).to eq('clip-units objectboundingbox')
    assert_nothing_raised { draw.draw(@img) }

    expect { @draw.clip_units('foo') }.to raise_error(ArgumentError)
  end

  def test_color
    draw = Magick::Draw.new
    draw.color(50.5, 50, Magick::PointMethod)
    expect(draw.inspect).to eq('color 50.5,50,point')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.color(50.5, 50, Magick::ReplaceMethod)
    expect(draw.inspect).to eq('color 50.5,50,replace')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.color(50.5, 50, Magick::FloodfillMethod)
    expect(draw.inspect).to eq('color 50.5,50,floodfill')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.color(50.5, 50, Magick::FillToBorderMethod)
    expect(draw.inspect).to eq('color 50.5,50,filltoborder')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.color(50.5, 50, Magick::ResetMethod)
    expect(draw.inspect).to eq('color 50.5,50,reset')
    assert_nothing_raised { draw.draw(@img) }

    expect { @draw.color(10, 20, 'unknown') }.to raise_error(ArgumentError)
    expect { @draw.color('x', 20, Magick::PointMethod) }.to raise_error(ArgumentError)
    expect { @draw.color(10, 'x', Magick::PointMethod) }.to raise_error(ArgumentError)
  end

  def test_decorate
    draw = Magick::Draw.new
    draw.decorate(Magick::NoDecoration)
    expect(draw.inspect).to eq('decorate none')
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.decorate(Magick::UnderlineDecoration)
    expect(draw.inspect).to eq('decorate underline')
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.decorate(Magick::OverlineDecoration)
    expect(draw.inspect).to eq('decorate overline')
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.decorate(Magick::OverlineDecoration)
    expect(draw.inspect).to eq('decorate overline')
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    # draw = Magick::Draw.new
    # draw.decorate('tomato')
    # expect(draw.inspect).to eq('decorate "tomato"')
    # draw.text(50, 50, 'Hello world')
    # assert_nothing_raised { draw.draw(@img) }
  end

  def test_define_clip_path
    assert_nothing_raised { @draw.define_clip_path('test') { @draw } }
    expect(@draw.inspect).to eq("push defs\npush clip-path \"test\"\npush graphic-context\npop graphic-context\npop clip-path\npop defs")
  end

  def test_ellipse
    @draw.ellipse(50.5, 30, 25, 25, 60, 120)
    expect(@draw.inspect).to eq('ellipse 50.5,30 25,25 60,120')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.ellipse('x', 20, 30, 40, 50, 60) }.to raise_error(ArgumentError)
    expect { @draw.ellipse(10, 'x', 30, 40, 50, 60) }.to raise_error(ArgumentError)
    expect { @draw.ellipse(10, 20, 'x', 40, 50, 60) }.to raise_error(ArgumentError)
    expect { @draw.ellipse(10, 20, 30, 'x', 50, 60) }.to raise_error(ArgumentError)
    expect { @draw.ellipse(10, 20, 30, 40, 'x', 60) }.to raise_error(ArgumentError)
    expect { @draw.ellipse(10, 20, 30, 40, 50, 'x') }.to raise_error(ArgumentError)
  end

  def test_encoding
    @draw.encoding('UTF-8')
    expect(@draw.inspect).to eq('encoding UTF-8')
    assert_nothing_raised { @draw.draw(@img) }
  end

  def test_fill
    draw = Magick::Draw.new
    draw.fill('tomato')
    expect(draw.inspect).to eq('fill "tomato"')
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.fill_color('tomato')
    expect(draw.inspect).to eq('fill "tomato"')
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.fill_pattern('tomato')
    expect(draw.inspect).to eq('fill "tomato"')
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }

    # draw = Magick::Draw.new
    # draw.fill_pattern('foo')
    # assert_nothing_raised { draw.draw(@img) }
  end

  def test_fill_opacity
    draw = Magick::Draw.new
    draw.fill_opacity(0.5)
    expect(draw.inspect).to eq('fill-opacity 0.5')
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.fill_opacity('50%')
    expect(draw.inspect).to eq('fill-opacity 50%')
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }

    assert_nothing_raised { @draw.fill_opacity(0.0) }
    assert_nothing_raised { @draw.fill_opacity(1.0) }
    assert_nothing_raised { @draw.fill_opacity('0.0') }
    assert_nothing_raised { @draw.fill_opacity('1.0') }
    assert_nothing_raised { @draw.fill_opacity('20%') }

    expect { @draw.fill_opacity(-0.01) }.to raise_error(ArgumentError)
    expect { @draw.fill_opacity(1.01) }.to raise_error(ArgumentError)
    expect { @draw.fill_opacity('-0.01') }.to raise_error(ArgumentError)
    expect { @draw.fill_opacity('1.01') }.to raise_error(ArgumentError)
    expect { @draw.fill_opacity('xxx') }.to raise_error(ArgumentError)
  end

  def test_fill_rule
    draw = Magick::Draw.new
    draw.fill_rule('evenodd')
    expect(draw.inspect).to eq('fill-rule evenodd')
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.fill_rule('nonzero')
    expect(draw.inspect).to eq('fill-rule nonzero')
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }

    expect { @draw.fill_rule('zero') }.to raise_error(ArgumentError)
  end

  def test_font
    draw = Magick::Draw.new
    font_name = Magick.fonts.first.name
    draw.font(font_name)
    expect(draw.inspect).to eq("font '#{font_name}'")
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }
  end

  def test_font_family
    draw = Magick::Draw.new
    draw.font_family('sans-serif')
    expect(draw.inspect).to eq("font-family 'sans-serif'")
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

    expect { @draw.font_stretch('xxx') }.to raise_error(ArgumentError)
  end

  def test_font_style
    draw = Magick::Draw.new
    draw.font_style(Magick::NormalStyle)
    expect(draw.inspect).to eq('font-style normal')
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.font_style(Magick::ItalicStyle)
    expect(draw.inspect).to eq('font-style italic')
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.font_style(Magick::ObliqueStyle)
    expect(draw.inspect).to eq('font-style oblique')
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    expect { @draw.font_style('xxx') }.to raise_error(ArgumentError)
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
    expect(draw.inspect).to eq('font-weight 400')
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    expect { @draw.font_weight('xxx') }.to raise_error(ArgumentError)
  end

  def test_gravity
    Magick::GravityType.values do |gravity|
      next if [Magick::UndefinedGravity].include?(gravity)

      draw = Magick::Draw.new
      draw.gravity(gravity)
      draw.circle(10, '20.5', 30, 40.5)
      assert_nothing_raised { draw.draw(@img) }
    end

    expect { @draw.gravity('xxx') }.to raise_error(ArgumentError)
  end

  def test_image
    Magick::CompositeOperator.values do |composite|
      next if [Magick::CopyAlphaCompositeOp, Magick::NoCompositeOp].include?(composite)

      draw = Magick::Draw.new
      draw.image(composite, 10, 10, 200, 100, "#{IMAGES_DIR}/Flower_Hat.jpg")
      assert_nothing_raised { draw.draw(@img) }
    end

    expect { @draw.image('xxx', 10, 10, 200, 100, "#{IMAGES_DIR}/Flower_Hat.jpg") }.to raise_error(ArgumentError)
    expect { @draw.image(Magick::AtopCompositeOp, 'x', 100, 200, 100, "#{IMAGES_DIR}/Flower_Hat.jpg") }.to raise_error(ArgumentError)
    expect { @draw.image(Magick::AtopCompositeOp, 100, 'x', 200, 100, "#{IMAGES_DIR}/Flower_Hat.jpg") }.to raise_error(ArgumentError)
    expect { @draw.image(Magick::AtopCompositeOp, 100, 100, 'x', 100, "#{IMAGES_DIR}/Flower_Hat.jpg") }.to raise_error(ArgumentError)
    expect { @draw.image(Magick::AtopCompositeOp, 100, 100, 200, 'x', "#{IMAGES_DIR}/Flower_Hat.jpg") }.to raise_error(ArgumentError)
  end

  def test_interline_spacing
    draw = Magick::Draw.new
    draw.interline_spacing(40.5)
    expect(draw.inspect).to eq('interline-spacing 40.5')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.interline_spacing('40.5')
    expect(draw.inspect).to eq('interline-spacing 40.5')
    assert_nothing_raised { draw.draw(@img) }

    # expect { @draw.interline_spacing(Float::NAN) }.to raise_error(ArgumentError)
    expect { @draw.interline_spacing('nan') }.to raise_error(ArgumentError)
    expect { @draw.interline_spacing('xxx') }.to raise_error(ArgumentError)
    expect { @draw.interline_spacing(nil) }.to raise_error(TypeError)
  end

  def test_interword_spacing
    draw = Magick::Draw.new
    draw.interword_spacing(40.5)
    expect(draw.inspect).to eq('interword-spacing 40.5')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.interword_spacing('40.5')
    expect(draw.inspect).to eq('interword-spacing 40.5')
    assert_nothing_raised { draw.draw(@img) }

    # expect { @draw.interword_spacing(Float::NAN) }.to raise_error(ArgumentError)
    expect { @draw.interword_spacing('nan') }.to raise_error(ArgumentError)
    expect { @draw.interword_spacing('xxx') }.to raise_error(ArgumentError)
    expect { @draw.interword_spacing(nil) }.to raise_error(TypeError)
  end

  def test_kerning
    draw = Magick::Draw.new
    draw.kerning(40.5)
    expect(draw.inspect).to eq('kerning 40.5')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.kerning('40.5')
    expect(draw.inspect).to eq('kerning 40.5')
    assert_nothing_raised { draw.draw(@img) }

    # expect { @draw.kerning(Float::NAN) }.to raise_error(ArgumentError)
    expect { @draw.kerning('nan') }.to raise_error(ArgumentError)
    expect { @draw.kerning('xxx') }.to raise_error(ArgumentError)
    expect { @draw.kerning(nil) }.to raise_error(TypeError)
  end

  def test_line
    @draw.line(10, '20.5', 30, 40.5)
    expect(@draw.inspect).to eq('line 10,20.5 30,40.5')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.line('x', '20.5', 30, 40.5) }.to raise_error(ArgumentError)
    expect { @draw.line(10, 'x', 30, 40.5) }.to raise_error(ArgumentError)
    expect { @draw.line(10, '20.5', 'x', 40.5) }.to raise_error(ArgumentError)
    expect { @draw.line(10, '20.5', 30, 'x') }.to raise_error(ArgumentError)
  end

  def test_opacity
    @draw.opacity(0.8)
    expect(@draw.inspect).to eq('opacity 0.8')
    assert_nothing_raised { @draw.draw(@img) }

    assert_nothing_raised { @draw.opacity(0.0) }
    assert_nothing_raised { @draw.opacity(1.0) }
    assert_nothing_raised { @draw.opacity('0.0') }
    assert_nothing_raised { @draw.opacity('1.0') }
    assert_nothing_raised { @draw.opacity('20%') }

    expect { @draw.opacity(-0.01) }.to raise_error(ArgumentError)
    expect { @draw.opacity(1.01) }.to raise_error(ArgumentError)
    expect { @draw.opacity('-0.01') }.to raise_error(ArgumentError)
    expect { @draw.opacity('1.01') }.to raise_error(ArgumentError)
    expect { @draw.opacity('xxx') }.to raise_error(ArgumentError)
  end

  def test_path
    @draw.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    expect(@draw.inspect).to eq("path 'M110,100 h-75 a75,75 0 1,0 75,-75 z'")
    assert_nothing_raised { @draw.draw(@img) }
  end

  def test_pattern
    @draw.pattern('hat', 0, 10.5, 20, '20') {}
    expect(@draw.inspect).to eq("push defs\npush pattern hat 0 10.5 20 20\npush graphic-context\npop graphic-context\npop pattern\npop defs")
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.pattern('hat', 'x', 0, 20, 20) {} }.to raise_error(ArgumentError)
    expect { @draw.pattern('hat', 0, 'x', 20, 20) {} }.to raise_error(ArgumentError)
    expect { @draw.pattern('hat', 0, 0, 'x', 20) {} }.to raise_error(ArgumentError)
    expect { @draw.pattern('hat', 0, 0, 20, 'x') {} }.to raise_error(ArgumentError)
  end

  def test_point
    @draw.point(10.5, '20')
    expect(@draw.inspect).to eq('point 10.5,20')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.point('x', 20) }.to raise_error(ArgumentError)
    expect { @draw.point(10, 'x') }.to raise_error(ArgumentError)
  end

  def test_pointsize
    @draw.pointsize(20.5)
    expect(@draw.inspect).to eq('font-size 20.5')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.pointsize('x') }.to raise_error(ArgumentError)
  end

  def test_font_size
    @draw.font_size(20)
    expect(@draw.inspect).to eq('font-size 20')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.font_size('x') }.to raise_error(ArgumentError)
  end

  def test_polygon
    @draw.polygon(0, '0.5', 8.5, 16, 16, 0, 0, 0)
    expect(@draw.inspect).to eq('polygon 0,0.5,8.5,16,16,0,0,0')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.polygon }.to raise_error(ArgumentError)
    expect { @draw.polygon(0) }.to raise_error(ArgumentError)
    expect { @draw.polygon('x', 0, 8, 16, 16, 0, 0, 0) }.to raise_error(ArgumentError)
  end

  def test_polyline
    @draw.polyline(0, '0.5', 16.5, 16)
    expect(@draw.inspect).to eq('polyline 0,0.5,16.5,16')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.polyline }.to raise_error(ArgumentError)
    expect { @draw.polyline(0) }.to raise_error(ArgumentError)
    expect { @draw.polyline('x', 0, 16, 16) }.to raise_error(ArgumentError)
  end

  def test_rectangle
    @draw.rectangle(10, '10', 100, 100)
    expect(@draw.inspect).to eq('rectangle 10,10 100,100')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.rectangle('x', 10, 20, 20) }.to raise_error(ArgumentError)
    expect { @draw.rectangle(10, 'x', 20, 20) }.to raise_error(ArgumentError)
    expect { @draw.rectangle(10, 10, 'x', 20) }.to raise_error(ArgumentError)
    expect { @draw.rectangle(10, 10, 20, 'x') }.to raise_error(ArgumentError)
  end

  def test_rotate
    @draw.rotate(45)
    expect(@draw.inspect).to eq('rotate 45')
    @draw.text(50, 50, 'Hello world')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.rotate('x') }.to raise_error(ArgumentError)
  end

  def test_roundrectangle
    @draw.roundrectangle(10, '10', 100, 100, 20, 20)
    expect(@draw.inspect).to eq('roundrectangle 10,10,100,100,20,20')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.roundrectangle('x', '10', 100, 100, 20, 20) }.to raise_error(ArgumentError)
    expect { @draw.roundrectangle(10, 'x', 100, 100, 20, 20) }.to raise_error(ArgumentError)
    expect { @draw.roundrectangle(10, '10', 'x', 100, 20, 20) }.to raise_error(ArgumentError)
    expect { @draw.roundrectangle(10, '10', 100, 'x', 20, 20) }.to raise_error(ArgumentError)
    expect { @draw.roundrectangle(10, '10', 100, 100, 'x', 20) }.to raise_error(ArgumentError)
    expect { @draw.roundrectangle(10, '10', 100, 100, 20, 'x') }.to raise_error(ArgumentError)
  end

  def test_scale
    @draw.scale('0.5', 1.5)
    expect(@draw.inspect).to eq('scale 0.5,1.5')
    @draw.rectangle(10, '10', 100, 100)
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.scale('x', 1.5) }.to raise_error(ArgumentError)
    expect { @draw.scale(0.5, 'x') }.to raise_error(ArgumentError)
  end

  def test_skewx
    @draw.skewx(45)
    expect(@draw.inspect).to eq('skewX 45')
    @draw.text(50, 50, 'Hello world')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.skewx('x') }.to raise_error(ArgumentError)
  end

  def test_skewy
    @draw.skewy(45)
    expect(@draw.inspect).to eq('skewY 45')
    @draw.text(50, 50, 'Hello world')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.skewy('x') }.to raise_error(ArgumentError)
  end

  def test_stroke
    @draw.stroke('red')
    expect(@draw.inspect).to eq('stroke "red"')
    @draw.rectangle(10, '10', 100, 100)
    assert_nothing_raised { @draw.draw(@img) }

    # expect { @draw.stroke(100) }.to raise_error(ArgumentError)
  end

  def test_stroke_color
    @draw.stroke_color('red')
    expect(@draw.inspect).to eq('stroke "red"')
    @draw.rectangle(10, '10', 100, 100)
    assert_nothing_raised { @draw.draw(@img) }

    # expect { @draw.stroke_color(100) }.to raise_error(ArgumentError)
  end

  def test_stroke_pattern
    @draw.stroke_pattern('red')
    expect(@draw.inspect).to eq('stroke "red"')
    @draw.rectangle(10, '10', 100, 100)
    assert_nothing_raised { @draw.draw(@img) }

    # expect { @draw.stroke_pattern(100) }.to raise_error(ArgumentError)
  end

  def test_stroke_antialias
    draw = Magick::Draw.new
    draw.stroke_antialias(true)
    expect(draw.inspect).to eq('stroke-antialias 1')
    draw.stroke_pattern('red')
    draw.stroke_width(5)
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.stroke_antialias(false)
    expect(draw.inspect).to eq('stroke-antialias 0')
    draw.stroke_pattern('red')
    draw.stroke_width(5)
    draw.circle(10, '20.5', 30, 40.5)
    assert_nothing_raised { draw.draw(@img) }
  end

  def test_stroke_dasharray
    draw = Magick::Draw.new
    draw.stroke_dasharray(2, 2)
    expect(draw.inspect).to eq('stroke-dasharray 2,2')
    draw.stroke_pattern('red')
    draw.stroke_width(2)
    draw.rectangle(10, '10', 100, 100)
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.stroke_dasharray
    expect(draw.inspect).to eq('stroke-dasharray none')
    assert_nothing_raised { draw.draw(@img) }

    expect { @draw.stroke_dasharray(-0.1) }.to raise_error(ArgumentError)
    expect { @draw.stroke_dasharray('x') }.to raise_error(ArgumentError)
  end

  def test_stroke_dashoffset
    @draw.stroke_dashoffset(10)
    expect(@draw.inspect).to eq('stroke-dashoffset 10')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.stroke_dashoffset('x') }.to raise_error(ArgumentError)
  end

  def test_stroke_linecap
    draw = Magick::Draw.new
    draw.stroke_linecap('butt')
    expect(draw.inspect).to eq('stroke-linecap butt')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.stroke_linecap('round')
    expect(draw.inspect).to eq('stroke-linecap round')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.stroke_linecap('square')
    expect(draw.inspect).to eq('stroke-linecap square')
    assert_nothing_raised { draw.draw(@img) }

    expect { @draw.stroke_linecap('foo') }.to raise_error(ArgumentError)
  end

  def test_stroke_linejoin
    draw = Magick::Draw.new
    draw.stroke_linejoin('round')
    expect(draw.inspect).to eq('stroke-linejoin round')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.stroke_linejoin('miter')
    expect(draw.inspect).to eq('stroke-linejoin miter')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.stroke_linejoin('bevel')
    expect(draw.inspect).to eq('stroke-linejoin bevel')
    assert_nothing_raised { draw.draw(@img) }

    expect { @draw.stroke_linejoin('foo') }.to raise_error(ArgumentError)
  end

  def test_stroke_miterlimit
    draw = Magick::Draw.new
    draw.stroke_miterlimit(1.0)
    expect(draw.inspect).to eq('stroke-miterlimit 1.0')
    assert_nothing_raised { draw.draw(@img) }

    expect { @draw.stroke_miterlimit(0.9) }.to raise_error(ArgumentError)
    expect { @draw.stroke_miterlimit('foo') }.to raise_error(ArgumentError)
  end

  def test_stroke_opacity
    @draw.stroke_opacity(0.8)
    expect(@draw.inspect).to eq('stroke-opacity 0.8')
    assert_nothing_raised { @draw.draw(@img) }

    assert_nothing_raised { @draw.stroke_opacity(0.0) }
    assert_nothing_raised { @draw.stroke_opacity(1.0) }
    assert_nothing_raised { @draw.stroke_opacity('0.0') }
    assert_nothing_raised { @draw.stroke_opacity('1.0') }
    assert_nothing_raised { @draw.stroke_opacity('20%') }

    expect { @draw.stroke_opacity(-0.01) }.to raise_error(ArgumentError)
    expect { @draw.stroke_opacity(1.01) }.to raise_error(ArgumentError)
    expect { @draw.stroke_opacity('-0.01') }.to raise_error(ArgumentError)
    expect { @draw.stroke_opacity('1.01') }.to raise_error(ArgumentError)
    expect { @draw.stroke_opacity('xxx') }.to raise_error(ArgumentError)
  end

  def test_stroke_width
    @draw.stroke_width(2.5)
    expect(@draw.inspect).to eq('stroke-width 2.5')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.stroke_width('xxx') }.to raise_error(ArgumentError)
  end

  def test_text
    draw = Magick::Draw.new
    draw.text(50, 50, 'Hello world')
    expect(draw.inspect).to eq("text 50,50 'Hello world'")
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text(50, 50, "Hello 'world'")
    expect(draw.inspect).to eq("text 50,50 \"Hello 'world'\"")
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text(50, 50, 'Hello "world"')
    expect(draw.inspect).to eq("text 50,50 'Hello \"world\"'")
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text(50, 50, "Hello 'world\"")
    expect(draw.inspect).to eq("text 50,50 {Hello 'world\"}")
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text(50, 50, "Hello {'world\"")
    expect(draw.inspect).to eq("text 50,50 {Hello {'world\"}")
    assert_nothing_raised { draw.draw(@img) }

    expect { @draw.text(50, 50, '') }.to raise_error(ArgumentError)
    expect { @draw.text('x', 50, 'Hello world') }.to raise_error(ArgumentError)
    expect { @draw.text(50, 'x', 'Hello world') }.to raise_error(ArgumentError)
  end

  def test_text_align
    draw = Magick::Draw.new
    draw.text_align(Magick::LeftAlign)
    expect(draw.inspect).to eq('text-align left')
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text_align(Magick::RightAlign)
    expect(draw.inspect).to eq('text-align right')
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text_align(Magick::CenterAlign)
    expect(draw.inspect).to eq('text-align center')
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    expect { @draw.text_align('x') }.to raise_error(ArgumentError)
  end

  def test_text_anchor
    draw = Magick::Draw.new
    draw.text_anchor(Magick::StartAnchor)
    expect(draw.inspect).to eq('text-anchor start')
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text_anchor(Magick::MiddleAnchor)
    expect(draw.inspect).to eq('text-anchor middle')
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text_anchor(Magick::EndAnchor)
    expect(draw.inspect).to eq('text-anchor end')
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    expect { @draw.text_anchor('x') }.to raise_error(ArgumentError)
  end

  def test_text_antialias
    draw = Magick::Draw.new
    draw.text_antialias(true)
    expect(draw.inspect).to eq('text-antialias 1')
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }

    draw = Magick::Draw.new
    draw.text_antialias(false)
    expect(draw.inspect).to eq('text-antialias 0')
    draw.text(50, 50, 'Hello world')
    assert_nothing_raised { draw.draw(@img) }
  end

  def test_text_undercolor
    @draw.text_undercolor('red')
    expect(@draw.inspect).to eq('text-undercolor "red"')
    @draw.text(50, 50, 'Hello world')
    assert_nothing_raised { @draw.draw(@img) }
  end

  def test_translate
    @draw.translate('200', 300)
    expect(@draw.inspect).to eq('translate 200,300')
    assert_nothing_raised { @draw.draw(@img) }

    expect { @draw.translate('x', 300) }.to raise_error(ArgumentError)
    expect { @draw.translate(200, 'x') }.to raise_error(ArgumentError)
  end
end
