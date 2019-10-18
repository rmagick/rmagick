require 'rmagick'
require 'minitest/autorun'

class PixelUT < Minitest::Test
  def setup
    @pixel = Magick::Pixel.from_color('brown')
  end

  def test_red
    expect { @pixel.red = 123 }.not_to raise_error
    expect(@pixel.red).to eq(123)
    expect { @pixel.red = 255.25 }.not_to raise_error
    expect(@pixel.red).to eq(255)
    expect { @pixel.red = 'x' }.to raise_error(TypeError)
  end

  def test_green
    expect { @pixel.green = 123 }.not_to raise_error
    expect(@pixel.green).to eq(123)
    expect { @pixel.green = 255.25 }.not_to raise_error
    expect(@pixel.green).to eq(255)
    expect { @pixel.green = 'x' }.to raise_error(TypeError)
  end

  def test_blue
    expect { @pixel.blue = 123 }.not_to raise_error
    expect(@pixel.blue).to eq(123)
    expect { @pixel.blue = 255.25 }.not_to raise_error
    expect(@pixel.blue).to eq(255)
    expect { @pixel.blue = 'x' }.to raise_error(TypeError)
  end

  def test_alpha
    expect { @pixel.alpha = 123 }.not_to raise_error
    expect(@pixel.alpha).to eq(123)
    expect { @pixel.alpha = 255.25 }.not_to raise_error
    expect(@pixel.alpha).to eq(255)
    expect { @pixel.alpha = 'x' }.to raise_error(TypeError)
  end

  def test_cyan
    expect { @pixel.cyan = 123 }.not_to raise_error
    expect(@pixel.cyan).to eq(123)
    expect { @pixel.cyan = 255.25 }.not_to raise_error
    expect(@pixel.cyan).to eq(255)
    expect { @pixel.cyan = 'x' }.to raise_error(TypeError)
  end

  def test_magenta
    expect { @pixel.magenta = 123 }.not_to raise_error
    expect(@pixel.magenta).to eq(123)
    expect { @pixel.magenta = 255.25 }.not_to raise_error
    expect(@pixel.magenta).to eq(255)
    expect { @pixel.magenta = 'x' }.to raise_error(TypeError)
  end

  def test_yellow
    expect { @pixel.yellow = 123 }.not_to raise_error
    expect(@pixel.yellow).to eq(123)
    expect { @pixel.yellow = 255.25 }.not_to raise_error
    expect(@pixel.yellow).to eq(255)
    expect { @pixel.yellow = 'x' }.to raise_error(TypeError)
  end

  def test_black
    expect { @pixel.black = 123 }.not_to raise_error
    expect(@pixel.black).to eq(123)
    expect { @pixel.black = 255.25 }.not_to raise_error
    expect(@pixel.black).to eq(255)
    expect { @pixel.black = 'x' }.to raise_error(TypeError)
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
    expect { hash = @pixel.hash }.not_to raise_error
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
    expect { red.fcmp(red) }.not_to raise_error
    assert(red.fcmp(red))
    assert(!red.fcmp(blue))

    expect { red.fcmp(blue, 10) }.not_to raise_error
    expect { red.fcmp(blue, 10, Magick::RGBColorspace) }.not_to raise_error
    expect { red.fcmp(blue, 'x') }.to raise_error(TypeError)
    expect { red.fcmp(blue, 10, 'x') }.to raise_error(TypeError)
    expect { red.fcmp }.to raise_error(ArgumentError)
    expect { red.fcmp(blue, 10, 'x', 'y') }.to raise_error(ArgumentError)
  end

  def test_from_hsla
    expect { Magick::Pixel.from_hsla(127, 50, 50) }.not_to raise_error
    expect { Magick::Pixel.from_hsla(127, 50, 50, 0) }.not_to raise_error
    expect { Magick::Pixel.from_hsla('99%', '100%', '100%', '100%') }.not_to raise_error
    expect { Magick::Pixel.from_hsla(0, 0, 0, 0) }.not_to raise_error
    expect { Magick::Pixel.from_hsla(359, 255, 255, 1.0) }.not_to raise_error
    expect { Magick::Pixel.from_hsla([], 50, 50, 0) }.to raise_error(TypeError)
    expect { Magick::Pixel.from_hsla(127, [], 50, 0) }.to raise_error(TypeError)
    expect { Magick::Pixel.from_hsla(127, 50, [], 0) }.to raise_error(TypeError)
    expect { Magick::Pixel.from_hsla }.to raise_error(ArgumentError)
    expect { Magick::Pixel.from_hsla(127, 50, 50, 50, 50) }.to raise_error(ArgumentError)
    expect { Magick::Pixel.from_hsla(-0.01, 0, 0) }.to raise_error(ArgumentError)
    expect { Magick::Pixel.from_hsla(0, -0.01, 0) }.to raise_error(ArgumentError)
    expect { Magick::Pixel.from_hsla(0, 0, -0.01) }.to raise_error(ArgumentError)
    expect { Magick::Pixel.from_hsla(0, 0, 0, -0.01) }.to raise_error(ArgumentError)
    expect { Magick::Pixel.from_hsla(0, 0, 0, 1.01) }.to raise_error(RangeError)
    expect { Magick::Pixel.from_hsla(360, 0, 0) }.to raise_error(RangeError)
    expect { Magick::Pixel.from_hsla(0, 256, 0) }.to raise_error(RangeError)
    expect { Magick::Pixel.from_hsla(0, 0, 256) }.to raise_error(RangeError)
    expect { @pixel.to_hsla }.not_to raise_error

    args = [200, 125.125, 250.5, 0.6]
    px = Magick::Pixel.from_hsla(*args)
    hsla = px.to_hsla
    expect(hsla[0]).to be_within(0.25).of(args[0])
    expect(hsla[1]).to be_within(0.25).of(args[1])
    expect(hsla[2]).to be_within(0.25).of(args[2])
    expect(hsla[3]).to be_within(0.005).of(args[3])

    # test percentages
    args = ['20%', '20%', '20%', '20%']
    args2 = [360.0 / 5, 255.0 / 5, 255.0 / 5, 1.0 / 5]
    px = Magick::Pixel.from_hsla(*args)
    hsla = px.to_hsla
    px2 = Magick::Pixel.from_hsla(*args2)
    hsla2 = px2.to_hsla

    expect(hsla2[0]).to be_within(0.25).of(hsla[0])
    expect(hsla2[1]).to be_within(0.25).of(hsla[1])
    expect(hsla2[2]).to be_within(0.25).of(hsla[2])
    expect(hsla2[3]).to be_within(0.005).of(hsla[3])
  end

  def test_intensity
    expect(@pixel.intensity).to be_kind_of(Integer)
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
    expect { @pixel.to_color(Magick::AllCompliance) }.not_to raise_error
    expect { @pixel.to_color(Magick::SVGCompliance) }.not_to raise_error
    expect { @pixel.to_color(Magick::X11Compliance) }.not_to raise_error
    expect { @pixel.to_color(Magick::XPMCompliance) }.not_to raise_error
    expect { @pixel.to_color(Magick::AllCompliance, true) }.not_to raise_error
    expect { @pixel.to_color(Magick::AllCompliance, false) }.not_to raise_error
    expect { @pixel.to_color(Magick::AllCompliance, false, 8) }.not_to raise_error
    expect { @pixel.to_color(Magick::AllCompliance, false, 16) }.not_to raise_error
    # test "hex" format
    expect { @pixel.to_color(Magick::AllCompliance, false, 8, true) }.not_to raise_error
    expect { @pixel.to_color(Magick::AllCompliance, false, 16, true) }.not_to raise_error

    expect(@pixel.to_color(Magick::AllCompliance, false, 8, true)).to eq('#A52A2A')
    expect(@pixel.to_color(Magick::AllCompliance, false, 16, true)).to eq('#A5A52A2A2A2A')

    expect { @pixel.to_color(Magick::AllCompliance, false, 32) }.to raise_error(ArgumentError)
    expect { @pixel.to_color(1) }.to raise_error(TypeError)
  end

  def test_to_s
    assert_match(/red=\d+, green=\d+, blue=\d+, alpha=\d+/, @pixel.to_s)
  end
end
