require 'rmagick'
require 'minitest/autorun'

class InfoUT < Minitest::Test
  def setup
    @info = Magick::Image::Info.new
  end

  def test_options
    # 1-argument form
    assert_nothing_raised { @info['fill'] }
    assert_nil(@info['fill'])

    assert_nothing_raised { @info['fill'] = 'red' }
    expect(@info['fill']).to eq('red')

    assert_nothing_raised { @info['fill'] = nil }
    assert_nil(@info['fill'])

    # 2-argument form
    assert_nothing_raised { @info['tiff', 'bits-per-sample'] = 2 }
    expect(@info['tiff', 'bits-per-sample']).to eq('2')

    # define and undefine
    assert_nothing_raised { @info.define('tiff', 'bits-per-sample', 4) }
    expect(@info['tiff', 'bits-per-sample']).to eq('4')

    assert_nothing_raised { @info.undefine('tiff', 'bits-per-sample') }
    assert_nil(@info['tiff', 'bits-per-sample'])
    expect { @info.undefine('tiff', 'a' * 10_000) }.to raise_error(ArgumentError)
  end

  def test_antialias
    assert @info.antialias
    assert_nothing_raised { @info.antialias = false }
    assert !@info.antialias
  end

  def test_aref_aset
    assert_nothing_raised { @info['tiff'] = 'xxx' }
    expect(@info['tiff']).to eq('xxx')
    assert_nothing_raised { @info['tiff', 'bits-per-sample'] = 'abc' }
    expect(@info['tiff', 'bits-per-sample']).to eq('abc')
    expect { @info['tiff', 'a', 'b'] }.to raise_error(ArgumentError)
    expect { @info['tiff', 'a' * 10_000] }.to raise_error(ArgumentError)
    expect { @info['tiff', 'a' * 10_000] = 'abc' }.to raise_error(ArgumentError)
    expect { @info['tiff', 'a', 'b'] = 'abc' }.to raise_error(ArgumentError)
  end

  def test_attenuate
    assert_nothing_raised { @info.attenuate = 10 }
    expect(@info.attenuate).to eq(10)
    assert_nothing_raised { @info.attenuate = 5.25 }
    expect(@info.attenuate).to eq(5.25)
    assert_nothing_raised { @info.attenuate = nil }
    assert_nil(@info.attenuate)
  end

  def test_authenticate
    assert_nothing_raised { @info.authenticate = 'string' }
    expect(@info.authenticate).to eq('string')
    assert_nothing_raised { @info.authenticate = nil }
    assert_nil(@info.authenticate)
    assert_nothing_raised { @info.authenticate = '' }
    expect(@info.authenticate).to eq('')
  end

  def test_background_color
    assert_nothing_raised { @info.background_color = 'red' }
    red = Magick::Pixel.new(Magick::QuantumRange)
    assert_nothing_raised { @info.background_color = red }
    expect(@info.background_color).to eq('red')
    img = Magick::Image.new(20, 20) { self.background_color = 'red' }
    expect(img.background_color).to eq('red')
  end

  def test_border_color
    assert_nothing_raised { @info.border_color = 'red' }
    red = Magick::Pixel.new(Magick::QuantumRange)
    assert_nothing_raised { @info.border_color = red }
    expect(@info.border_color).to eq('red')
    img = Magick::Image.new(20, 20) { self.border_color = 'red' }
    expect(img.border_color).to eq('red')
  end

  def test_caption
    assert_nothing_raised { @info.caption = 'string' }
    expect(@info.caption).to eq('string')
    assert_nothing_raised { @info.caption = nil }
    assert_nil(@info.caption)
    assert_nothing_raised { Magick::Image.new(20, 20) { self.caption = 'string' } }
  end

  def test_channel
    assert_nothing_raised { @info.channel(Magick::RedChannel) }
    assert_nothing_raised { @info.channel(Magick::RedChannel, Magick::BlueChannel) }
    expect { @info.channel(1) }.to raise_error(TypeError)
    expect { @info.channel(Magick::RedChannel, 1) }.to raise_error(TypeError)
  end

  def test_colorspace
    Magick::ColorspaceType.values.each do |cs|
      assert_nothing_raised { @info.colorspace = cs }
      expect(@info.colorspace).to eq(cs)
    end
  end

  def test_comment
    assert_nothing_raised { @info.comment = 'comment' }
    expect(@info.comment).to eq('comment')
  end

  def test_compression
    Magick::CompressionType.values.each do |v|
      assert_nothing_raised { @info.compression = v }
      expect(@info.compression).to eq(v)
    end
  end

  def test_define
    assert_nothing_raised { @info.define('tiff', 'bits-per-sample', 2) }
    assert_nothing_raised { @info.undefine('tiff', 'bits-per-sample') }
    expect { @info.define('tiff', 'bits-per-sample', 2, 2) }.to raise_error(ArgumentError)
    expect { @info.define('tiff', 'a' * 10_000) }.to raise_error(ArgumentError)
  end

  def test_density
    assert_nothing_raised { @info.density = '72x72' }
    expect(@info.density).to eq('72x72')
    assert_nothing_raised { @info.density = Magick::Geometry.new(72, 72) }
    expect(@info.density).to eq('72x72')
    assert_nothing_raised { @info.density = nil }
    assert_nil(@info.density)
    expect { @info.density = 'aaa' }.to raise_error(ArgumentError)
  end

  def test_delay
    assert_nothing_raised { @info.delay = 60 }
    expect(@info.delay).to eq(60)
    assert_nothing_raised { @info.delay = nil }
    assert_nil(@info.delay)
    expect { @info.delay = '60' }.to raise_error(TypeError)
  end

  def test_depth
    assert_nothing_raised { @info.depth = 8 }
    expect(@info.depth).to eq(8)
    assert_nothing_raised { @info.depth = 16 }
    expect(@info.depth).to eq(16)
    expect { @info.depth = 32 }.to raise_error(ArgumentError)
  end

  def test_dispose
    Magick::DisposeType.values.each do |v|
      assert_nothing_raised { @info.dispose = v }
      expect(@info.dispose).to eq(v)
    end
    assert_nothing_raised { @info.dispose = nil }
  end

  def test_dither
    assert_nothing_raised { @info.dither = true }
    expect(@info.dither).to eq(true)
    assert_nothing_raised { @info.dither = false }
    expect(@info.dither).to eq(false)
  end

  def test_endian
    assert_nothing_raised { @info.endian = Magick::LSBEndian }
    expect(@info.endian).to eq(Magick::LSBEndian)
    assert_nothing_raised { @info.endian = nil }
  end

  def test_extract
    assert_nothing_raised { @info.extract = '100x100' }
    expect(@info.extract).to eq('100x100')
    assert_nothing_raised { @info.extract = Magick::Geometry.new(100, 100) }
    expect(@info.extract).to eq('100x100')
    assert_nothing_raised { @info.extract = nil }
    assert_nil(@info.extract)
    expect { @info.extract = 'aaa' }.to raise_error(ArgumentError)
  end

  def test_filename
    assert_nothing_raised { @info.filename = 'string' }
    expect(@info.filename).to eq('string')
    assert_nothing_raised { @info.filename = nil }
    expect(@info.filename).to eq('')
  end

  def test_fill
    assert_nothing_raised { @info.fill }
    assert_nil(@info.fill)

    assert_nothing_raised { @info.fill = 'white' }
    expect(@info.fill).to eq('white')

    assert_nothing_raised { @info.fill = nil }
    assert_nil(@info.fill)

    expect { @info.fill = 'xxx' }.to raise_error(ArgumentError)
  end

  def test_font
    assert_nothing_raised { @info.font = 'Arial' }
    expect(@info.font).to eq('Arial')
    assert_nothing_raised { @info.font = nil }
    assert_nil(@info.font)
  end

  def test_format
    assert_nothing_raised { @info.format = 'GIF' }
    expect(@info.format).to eq('GIF')
    expect { @info.format = nil }.to raise_error(TypeError)
  end

  def test_fuzz
    assert_nothing_raised { @info.fuzz = 50 }
    expect(@info.fuzz).to eq(50)
    assert_nothing_raised { @info.fuzz = '50%' }
    expect(@info.fuzz).to eq(Magick::QuantumRange * 0.5)
    expect { @info.fuzz = nil }.to raise_error(TypeError)
    expect { @info.fuzz = 'xxx' }.to raise_error(ArgumentError)
  end

  def test_gravity
    Magick::GravityType.values.each do |v|
      assert_nothing_raised { @info.gravity = v }
      expect(@info.gravity).to eq(v)
    end
    assert_nothing_raised { @info.gravity = nil }
  end

  def test_image_type
    Magick::ImageType.values.each do |v|
      assert_nothing_raised { @info.image_type = v }
      expect(@info.image_type).to eq(v)
    end
    expect { @info.image_type = nil }.to raise_error(TypeError)
  end

  def test_interlace
    Magick::InterlaceType.values.each do |v|
      assert_nothing_raised { @info.interlace = v }
      expect(@info.interlace).to eq(v)
    end
    expect { @info.interlace = nil }.to raise_error(TypeError)
  end

  def test_label
    assert_nothing_raised { @info.label = 'string' }
    expect(@info.label).to eq('string')
    assert_nothing_raised { @info.label = nil }
    assert_nil(@info.label)
  end

  def test_matte_color
    assert_nothing_raised { @info.matte_color = 'red' }
    red = Magick::Pixel.new(Magick::QuantumRange)
    assert_nothing_raised { @info.matte_color = red }
    expect(@info.matte_color).to eq('red')
    img = Magick::Image.new(20, 20) { self.matte_color = 'red' }
    expect(img.matte_color).to eq('red')
    expect { @info.matte_color = nil }.to raise_error(TypeError)
  end

  def test_monitor
    assert_nothing_raised { @info.monitor = -> {} }
    monitor = proc do |mth, q, s|
      expect(mth).to eq('resize!')
      assert_kind_of(Integer, q)
      assert_kind_of(Integer, s)
      GC.start
      true
    end
    img = Magick::Image.new(2000, 2000) { self.monitor = monitor }
    img.resize!(20, 20)
    img.monitor = nil

    assert_nothing_raised { @info.monitor = nil }
  end

  def test_monochrome
    assert_nothing_raised { @info.monochrome = true }
    assert @info.monochrome
    assert_nothing_raised { @info.monochrome = nil }
  end

  def test_number_scenes
    assert_kind_of(Integer, @info.number_scenes)
    assert_nothing_raised { @info.number_scenes = 50 }
    expect(@info.number_scenes).to eq(50)
    expect { @info.number_scenes = nil }.to raise_error(TypeError)
    expect { @info.number_scenes = 'xxx' }.to raise_error(TypeError)
  end

  def test_orientation
    Magick::OrientationType.values.each do |v|
      assert_nothing_raised { @info.orientation = v }
      expect(@info.orientation).to eq(v)
    end
    expect { @info.orientation = nil }.to raise_error(TypeError)
  end

  def test_origin
    assert_nothing_raised { @info.origin = '+10+10' }
    expect(@info.origin).to eq('+10+10')
    assert_nothing_raised { @info.origin = Magick::Geometry.new(nil, nil, 10, 10) }
    expect(@info.origin).to eq('+10+10')
    assert_nothing_raised { @info.origin = nil }
    assert_nil(@info.origin)
    expect { @info.origin = 'aaa' }.to raise_error(ArgumentError)
  end

  def test_page
    assert_nothing_raised { @info.page = '612x792>' }
    expect(@info.page).to eq('612x792>')
    assert_nothing_raised { @info.page = nil }
    assert_nil(@info.page)
  end

  def test_pointsize
    assert_nothing_raised { @info.pointsize = 12 }
    expect(@info.pointsize).to eq(12)
  end

  def test_quality
    assert_nothing_raised { @info.quality = 75 }
    expect(@info.quality).to eq(75)
  end

  def test_sampling_factor
    assert_nothing_raised { @info.sampling_factor = '2x1' }
    expect(@info.sampling_factor).to eq('2x1')
    assert_nothing_raised { @info.sampling_factor = nil }
    assert_nil(@info.sampling_factor)
  end

  def test_scene
    assert_nothing_raised { @info.scene = 123 }
    expect(@info.scene).to eq(123)
    expect { @info.scene = 'xxx' }.to raise_error(TypeError)
  end

  def test_server_name
    assert_nothing_raised { @info.server_name = 'foo' }
    expect(@info.server_name).to eq('foo')
    assert_nothing_raised { @info.server_name = nil }
    assert_nil(@info.server_name)
  end

  def test_size
    assert_nothing_raised { @info.size = '200x100' }
    expect(@info.size).to eq('200x100')
    assert_nothing_raised { @info.size = Magick::Geometry.new(100, 200) }
    expect(@info.size).to eq('100x200')
    assert_nothing_raised { @info.size = nil }
    assert_nil(@info.size)
    expect { @info.size = 'aaa' }.to raise_error(ArgumentError)
  end

  def test_stroke
    assert_nothing_raised { @info.stroke }
    assert_nil(@info.stroke)

    assert_nothing_raised { @info.stroke = 'white' }
    expect(@info.stroke).to eq('white')

    assert_nothing_raised { @info.stroke = nil }
    assert_nil(@info.stroke)

    expect { @info.stroke = 'xxx' }.to raise_error(ArgumentError)
  end

  def test_stroke_width
    assert_nothing_raised { @info.stroke_width = 10 }
    expect(@info.stroke_width).to eq(10)
    assert_nothing_raised { @info.stroke_width = 5.25 }
    expect(@info.stroke_width).to eq(5.25)
    assert_nothing_raised { @info.stroke_width = nil }
    assert_nil(@info.stroke_width)
    expect { @info.stroke_width = 'xxx' }.to raise_error(TypeError)
  end

  def test_texture
    img = Magick::Image.read('granite:') { self.size = '20x20' }
    assert_nothing_raised { @info.texture = img.first }
    assert_nothing_raised { @info.texture = nil }
  end

  def test_tile_offset
    assert_nothing_raised { @info.tile_offset = '200x100' }
    expect(@info.tile_offset).to eq('200x100')
    assert_nothing_raised { @info.tile_offset = Magick::Geometry.new(100, 200) }
    expect(@info.tile_offset).to eq('100x200')
    expect { @info.tile_offset = nil }.to raise_error(ArgumentError)
  end

  def test_transparent_color
    assert_nothing_raised { @info.transparent_color = 'white' }
    expect(@info.transparent_color).to eq('white')
    expect { @info.transparent_color = nil }.to raise_error(TypeError)
  end

  def test_undercolor
    assert_nothing_raised { @info.undercolor }
    assert_nil(@info.undercolor)

    assert_nothing_raised { @info.undercolor = 'white' }
    expect(@info.undercolor).to eq('white')

    assert_nothing_raised { @info.undercolor = nil }
    assert_nil(@info.undercolor)

    expect { @info.undercolor = 'xxx' }.to raise_error(ArgumentError)
  end

  def test_units
    Magick::ResolutionType.values.each do |v|
      assert_nothing_raised { @info.units = v }
      expect(@info.units).to eq(v)
    end
  end

  def test_view
    assert_nothing_raised { @info.view = 'string' }
    expect(@info.view).to eq('string')
    assert_nothing_raised { @info.view = nil }
    assert_nil(@info.view)
    assert_nothing_raised { @info.view = '' }
    expect(@info.view).to eq('')
  end
end
