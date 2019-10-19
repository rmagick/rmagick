require 'rmagick'
require 'minitest/autorun'

class PixelUT < Minitest::Test
  def setup
    @pixel = Magick::Pixel.from_color('brown')
  end

  def test_red
    assert_nothing_raised { @pixel.red = 123 }
    expect(@pixel.red).to eq(123)
    assert_nothing_raised { @pixel.red = 255.25 }
    expect(@pixel.red).to eq(255)
    assert_raise(TypeError) { @pixel.red = 'x' }
  end

  def test_green
    assert_nothing_raised { @pixel.green = 123 }
    expect(@pixel.green).to eq(123)
    assert_nothing_raised { @pixel.green = 255.25 }
    expect(@pixel.green).to eq(255)
    assert_raise(TypeError) { @pixel.green = 'x' }
  end

  def test_blue
    assert_nothing_raised { @pixel.blue = 123 }
    expect(@pixel.blue).to eq(123)
    assert_nothing_raised { @pixel.blue = 255.25 }
    expect(@pixel.blue).to eq(255)
    assert_raise(TypeError) { @pixel.blue = 'x' }
  end

  def test_alpha
    assert_nothing_raised { @pixel.alpha = 123 }
    expect(@pixel.alpha).to eq(123)
    assert_nothing_raised { @pixel.alpha = 255.25 }
    expect(@pixel.alpha).to eq(255)
    assert_raise(TypeError) { @pixel.alpha = 'x' }
  end

  def test_cyan
    assert_nothing_raised { @pixel.cyan = 123 }
    expect(@pixel.cyan).to eq(123)
    assert_nothing_raised { @pixel.cyan = 255.25 }
    expect(@pixel.cyan).to eq(255)
    assert_raise(TypeError) { @pixel.cyan = 'x' }
  end

  def test_magenta
    assert_nothing_raised { @pixel.magenta = 123 }
    expect(@pixel.magenta).to eq(123)
    assert_nothing_raised { @pixel.magenta = 255.25 }
    expect(@pixel.magenta).to eq(255)
    assert_raise(TypeError) { @pixel.magenta = 'x' }
  end

  def test_yellow
    assert_nothing_raised { @pixel.yellow = 123 }
    expect(@pixel.yellow).to eq(123)
    assert_nothing_raised { @pixel.yellow = 255.25 }
    expect(@pixel.yellow).to eq(255)
    assert_raise(TypeError) { @pixel.yellow = 'x' }
  end

  def test_black
    assert_nothing_raised { @pixel.black = 123 }
    expect(@pixel.black).to eq(123)
    assert_nothing_raised { @pixel.black = 255.25 }
    expect(@pixel.black).to eq(255)
    assert_raise(TypeError) { @pixel.black = 'x' }
  end

  def test_case_eq
    pixel = Magick::Pixel.from_color('brown')
    assert_true(@pixel === pixel)
    assert_false(@pixel === 'red')

    pixel = Magick::Pixel.from_color('red')
    assert_false(@pixel === pixel)
  end

  def test_clone
    pixel = @pixel.clone
    assert_true(@pixel === pixel)
    assert_not_equal(@pixel.object_id, pixel.object_id)

    pixel = @pixel.taint.clone
    assert_true(pixel.tainted?)

    pixel = @pixel.freeze.clone
    assert_true(pixel.frozen?)
  end

  def test_dup
    pixel = @pixel.dup
    assert_true(@pixel === pixel)
    assert_not_equal(@pixel.object_id, pixel.object_id)

    pixel = @pixel.taint.dup
    assert_true(pixel.tainted?)

    pixel = @pixel.freeze.dup
    assert_false(pixel.frozen?)
  end

  def test_hash
    hash = nil
    assert_nothing_raised { hash = @pixel.hash }
    assert_not_nil(hash)
    expect(hash).to eq(1_385_502_079)

    p = Magick::Pixel.new
    expect(p.hash).to eq(127)

    p = Magick::Pixel.from_color('red')
    expect(p.hash).to eq(2_139_095_167)

    # Pixel.hash sacrifices the last bit of the opacity channel
    p = Magick::Pixel.new(0, 0, 0, 72)
    p2 = Magick::Pixel.new(0, 0, 0, 73)
    assert_not_equal(p, p2)
    expect(p2.hash).to eq(p.hash)
  end

  def test_eql?
    p = @pixel
    assert(@pixel.eql?(p))
    p = Magick::Pixel.new
    assert(!@pixel.eql?(p))
  end

  def test_fcmp
    red = Magick::Pixel.from_color('red')
    blue = Magick::Pixel.from_color('blue')
    assert_nothing_raised { red.fcmp(red) }
    assert(red.fcmp(red))
    assert(!red.fcmp(blue))

    assert_nothing_raised { red.fcmp(blue, 10) }
    assert_nothing_raised { red.fcmp(blue, 10, Magick::RGBColorspace) }
    assert_raises(TypeError) { red.fcmp(blue, 'x') }
    assert_raises(TypeError) { red.fcmp(blue, 10, 'x') }
    assert_raises(ArgumentError) { red.fcmp }
    assert_raises(ArgumentError) { red.fcmp(blue, 10, 'x', 'y') }
  end

  def test_from_hsla
    assert_nothing_raised { Magick::Pixel.from_hsla(127, 50, 50) }
    assert_nothing_raised { Magick::Pixel.from_hsla(127, 50, 50, 0) }
    assert_nothing_raised { Magick::Pixel.from_hsla('99%', '100%', '100%', '100%') }
    assert_nothing_raised { Magick::Pixel.from_hsla(0, 0, 0, 0) }
    assert_nothing_raised { Magick::Pixel.from_hsla(359, 255, 255, 1.0) }
    assert_raise(TypeError) { Magick::Pixel.from_hsla([], 50, 50, 0) }
    assert_raise(TypeError) { Magick::Pixel.from_hsla(127, [], 50, 0) }
    assert_raise(TypeError) { Magick::Pixel.from_hsla(127, 50, [], 0) }
    assert_raise(ArgumentError) { Magick::Pixel.from_hsla }
    assert_raise(ArgumentError) { Magick::Pixel.from_hsla(127, 50, 50, 50, 50) }
    assert_raise(ArgumentError) { Magick::Pixel.from_hsla(-0.01, 0, 0) }
    assert_raise(ArgumentError) { Magick::Pixel.from_hsla(0, -0.01, 0) }
    assert_raise(ArgumentError) { Magick::Pixel.from_hsla(0, 0, -0.01) }
    assert_raise(ArgumentError) { Magick::Pixel.from_hsla(0, 0, 0, -0.01) }
    assert_raise(RangeError) { Magick::Pixel.from_hsla(0, 0, 0, 1.01) }
    assert_raise(RangeError) { Magick::Pixel.from_hsla(360, 0, 0) }
    assert_raise(RangeError) { Magick::Pixel.from_hsla(0, 256, 0) }
    assert_raise(RangeError) { Magick::Pixel.from_hsla(0, 0, 256) }
    assert_nothing_raised { @pixel.to_hsla }

    args = [200, 125.125, 250.5, 0.6]
    px = Magick::Pixel.from_hsla(*args)
    hsla = px.to_hsla
    assert_in_delta(args[0], hsla[0], 0.25, "expected #{args.inspect} got #{hsla.inspect}")
    assert_in_delta(args[1], hsla[1], 0.25, "expected #{args.inspect} got #{hsla.inspect}")
    assert_in_delta(args[2], hsla[2], 0.25, "expected #{args.inspect} got #{hsla.inspect}")
    assert_in_delta(args[3], hsla[3], 0.005, "expected #{args.inspect} got #{hsla.inspect}")

    # test percentages
    args = ['20%', '20%', '20%', '20%']
    args2 = [360.0 / 5, 255.0 / 5, 255.0 / 5, 1.0 / 5]
    px = Magick::Pixel.from_hsla(*args)
    hsla = px.to_hsla
    px2 = Magick::Pixel.from_hsla(*args2)
    hsla2 = px2.to_hsla

    assert_in_delta(hsla[0], hsla2[0], 0.25, "#{hsla.inspect} != #{hsla2.inspect} with args: #{args.inspect} and #{args2.inspect}")
    assert_in_delta(hsla[1], hsla2[1], 0.25, "#{hsla.inspect} != #{hsla2.inspect} with args: #{args.inspect} and #{args2.inspect}")
    assert_in_delta(hsla[2], hsla2[2], 0.25, "#{hsla.inspect} != #{hsla2.inspect} with args: #{args.inspect} and #{args2.inspect}")
    assert_in_delta(hsla[3], hsla2[3], 0.005, "#{hsla.inspect} != #{hsla2.inspect} with args: #{args.inspect} and #{args2.inspect}")
  end

  def test_intensity
    assert_kind_of(Integer, @pixel.intensity)
  end

  def test_marshal
    marshal = @pixel.marshal_dump

    pixel = Magick::Pixel.new
    expect(pixel.marshal_load(marshal)).to eq(@pixel)
  end

  def test_spaceship
    @pixel.red = 100
    pixel = @pixel.dup
    expect(@pixel <=> pixel).to eq(0)

    pixel.red -= 10
    expect(@pixel <=> pixel).to eq(1)
    pixel.red += 20
    expect(@pixel <=> pixel).to eq(-1)

    @pixel.green = 100
    pixel = @pixel.dup
    pixel.green -= 10
    expect(@pixel <=> pixel).to eq(1)
    pixel.green += 20
    expect(@pixel <=> pixel).to eq(-1)

    @pixel.blue = 100
    pixel = @pixel.dup
    pixel.blue -= 10
    expect(@pixel <=> pixel).to eq(1)
    pixel.blue += 20
    expect(@pixel <=> pixel).to eq(-1)

    @pixel.alpha = 100
    pixel = @pixel.dup
    pixel.alpha -= 10
    expect(@pixel <=> pixel).to eq(1)
    pixel.alpha += 20
    expect(@pixel <=> pixel).to eq(-1)
  end

  def test_to_color
    assert_nothing_raised { @pixel.to_color(Magick::AllCompliance) }
    assert_nothing_raised { @pixel.to_color(Magick::SVGCompliance) }
    assert_nothing_raised { @pixel.to_color(Magick::X11Compliance) }
    assert_nothing_raised { @pixel.to_color(Magick::XPMCompliance) }
    assert_nothing_raised { @pixel.to_color(Magick::AllCompliance, true) }
    assert_nothing_raised { @pixel.to_color(Magick::AllCompliance, false) }
    assert_nothing_raised { @pixel.to_color(Magick::AllCompliance, false, 8) }
    assert_nothing_raised { @pixel.to_color(Magick::AllCompliance, false, 16) }
    # test "hex" format
    assert_nothing_raised { @pixel.to_color(Magick::AllCompliance, false, 8, true) }
    assert_nothing_raised { @pixel.to_color(Magick::AllCompliance, false, 16, true) }

    expect(@pixel.to_color(Magick::AllCompliance, false, 8, true)).to eq('#A52A2A')
    expect(@pixel.to_color(Magick::AllCompliance, false, 16, true)).to eq('#A5A52A2A2A2A')

    assert_raise(ArgumentError) { @pixel.to_color(Magick::AllCompliance, false, 32) }
    assert_raise(TypeError) { @pixel.to_color(1) }
  end

  def test_to_s
    assert_match(/red=\d+, green=\d+, blue=\d+, alpha=\d+/, @pixel.to_s)
  end
end
