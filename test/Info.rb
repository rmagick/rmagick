require 'rmagick'
require 'minitest/autorun'

class InfoUT < Minitest::Test
  def setup
    @info = Magick::Image::Info.new
  end

  def test_options
    # 1-argument form
    expect { @info['fill'] }.not_to raise_error
    expect(@info['fill']).to be(nil)

    expect { @info['fill'] = 'red' }.not_to raise_error
    expect(@info['fill']).to eq('red')

    expect { @info['fill'] = nil }.not_to raise_error
    expect(@info['fill']).to be(nil)

    # 2-argument form
    expect { @info['tiff', 'bits-per-sample'] = 2 }.not_to raise_error
    expect(@info['tiff', 'bits-per-sample']).to eq('2')

    # define and undefine
    expect { @info.define('tiff', 'bits-per-sample', 4) }.not_to raise_error
    expect(@info['tiff', 'bits-per-sample']).to eq('4')

    expect { @info.undefine('tiff', 'bits-per-sample') }.not_to raise_error
    expect(@info['tiff', 'bits-per-sample']).to be(nil)
    expect { @info.undefine('tiff', 'a' * 10_000) }.to raise_error(ArgumentError)
  end

  def test_antialias
    expect(@info.antialias).to be(true)
    expect { @info.antialias = false }.not_to raise_error
    expect(@info.antialias).to be(false)
  end

  def test_aref_aset
    expect { @info['tiff'] = 'xxx' }.not_to raise_error
    expect(@info['tiff']).to eq('xxx')
    expect { @info['tiff', 'bits-per-sample'] = 'abc' }.not_to raise_error
    expect(@info['tiff', 'bits-per-sample']).to eq('abc')
    expect { @info['tiff', 'a', 'b'] }.to raise_error(ArgumentError)
    expect { @info['tiff', 'a' * 10_000] }.to raise_error(ArgumentError)
    expect { @info['tiff', 'a' * 10_000] = 'abc' }.to raise_error(ArgumentError)
    expect { @info['tiff', 'a', 'b'] = 'abc' }.to raise_error(ArgumentError)
  end

  def test_attenuate
    expect { @info.attenuate = 10 }.not_to raise_error
    expect(@info.attenuate).to eq(10)
    expect { @info.attenuate = 5.25 }.not_to raise_error
    expect(@info.attenuate).to eq(5.25)
    expect { @info.attenuate = nil }.not_to raise_error
    expect(@info.attenuate).to be(nil)
  end

  def test_authenticate
    expect { @info.authenticate = 'string' }.not_to raise_error
    expect(@info.authenticate).to eq('string')
    expect { @info.authenticate = nil }.not_to raise_error
    expect(@info.authenticate).to be(nil)
    expect { @info.authenticate = '' }.not_to raise_error
    expect(@info.authenticate).to eq('')
  end

  def test_background_color
    expect { @info.background_color = 'red' }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { @info.background_color = red }.not_to raise_error
    expect(@info.background_color).to eq('red')
    img = Magick::Image.new(20, 20) { self.background_color = 'red' }
    expect(img.background_color).to eq('red')
  end

  def test_border_color
    expect { @info.border_color = 'red' }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { @info.border_color = red }.not_to raise_error
    expect(@info.border_color).to eq('red')
    img = Magick::Image.new(20, 20) { self.border_color = 'red' }
    expect(img.border_color).to eq('red')
  end

  def test_caption
    expect { @info.caption = 'string' }.not_to raise_error
    expect(@info.caption).to eq('string')
    expect { @info.caption = nil }.not_to raise_error
    expect(@info.caption).to be(nil)
    expect { Magick::Image.new(20, 20) { self.caption = 'string' } }.not_to raise_error
  end

  def test_channel
    expect { @info.channel(Magick::RedChannel) }.not_to raise_error
    expect { @info.channel(Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @info.channel(1) }.to raise_error(TypeError)
    expect { @info.channel(Magick::RedChannel, 1) }.to raise_error(TypeError)
  end

  def test_colorspace
    Magick::ColorspaceType.values.each do |cs|
      expect { @info.colorspace = cs }.not_to raise_error
      expect(@info.colorspace).to eq(cs)
    end
  end

  def test_comment
    expect { @info.comment = 'comment' }.not_to raise_error
    expect(@info.comment).to eq('comment')
  end

  def test_compression
    Magick::CompressionType.values.each do |v|
      expect { @info.compression = v }.not_to raise_error
      expect(@info.compression).to eq(v)
    end
  end

  def test_define
    expect { @info.define('tiff', 'bits-per-sample', 2) }.not_to raise_error
    expect { @info.undefine('tiff', 'bits-per-sample') }.not_to raise_error
    expect { @info.define('tiff', 'bits-per-sample', 2, 2) }.to raise_error(ArgumentError)
    expect { @info.define('tiff', 'a' * 10_000) }.to raise_error(ArgumentError)
  end

  def test_density
    expect { @info.density = '72x72' }.not_to raise_error
    expect(@info.density).to eq('72x72')
    expect { @info.density = Magick::Geometry.new(72, 72) }.not_to raise_error
    expect(@info.density).to eq('72x72')
    expect { @info.density = nil }.not_to raise_error
    expect(@info.density).to be(nil)
    expect { @info.density = 'aaa' }.to raise_error(ArgumentError)
  end

  def test_delay
    expect { @info.delay = 60 }.not_to raise_error
    expect(@info.delay).to eq(60)
    expect { @info.delay = nil }.not_to raise_error
    expect(@info.delay).to be(nil)
    expect { @info.delay = '60' }.to raise_error(TypeError)
  end

  def test_depth
    expect { @info.depth = 8 }.not_to raise_error
    expect(@info.depth).to eq(8)
    expect { @info.depth = 16 }.not_to raise_error
    expect(@info.depth).to eq(16)
    expect { @info.depth = 32 }.to raise_error(ArgumentError)
  end

  def test_dispose
    Magick::DisposeType.values.each do |v|
      expect { @info.dispose = v }.not_to raise_error
      expect(@info.dispose).to eq(v)
    end
    expect { @info.dispose = nil }.not_to raise_error
  end

  def test_dither
    expect { @info.dither = true }.not_to raise_error
    expect(@info.dither).to eq(true)
    expect { @info.dither = false }.not_to raise_error
    expect(@info.dither).to eq(false)
  end

  def test_endian
    expect { @info.endian = Magick::LSBEndian }.not_to raise_error
    expect(@info.endian).to eq(Magick::LSBEndian)
    expect { @info.endian = nil }.not_to raise_error
  end

  def test_extract
    expect { @info.extract = '100x100' }.not_to raise_error
    expect(@info.extract).to eq('100x100')
    expect { @info.extract = Magick::Geometry.new(100, 100) }.not_to raise_error
    expect(@info.extract).to eq('100x100')
    expect { @info.extract = nil }.not_to raise_error
    expect(@info.extract).to be(nil)
    expect { @info.extract = 'aaa' }.to raise_error(ArgumentError)
  end

  def test_filename
    expect { @info.filename = 'string' }.not_to raise_error
    expect(@info.filename).to eq('string')
    expect { @info.filename = nil }.not_to raise_error
    expect(@info.filename).to eq('')
  end

  def test_fill
    expect { @info.fill }.not_to raise_error
    expect(@info.fill).to be(nil)

    expect { @info.fill = 'white' }.not_to raise_error
    expect(@info.fill).to eq('white')

    expect { @info.fill = nil }.not_to raise_error
    expect(@info.fill).to be(nil)

    expect { @info.fill = 'xxx' }.to raise_error(ArgumentError)
  end

  def test_font
    expect { @info.font = 'Arial' }.not_to raise_error
    expect(@info.font).to eq('Arial')
    expect { @info.font = nil }.not_to raise_error
    expect(@info.font).to be(nil)
  end

  def test_format
    expect { @info.format = 'GIF' }.not_to raise_error
    expect(@info.format).to eq('GIF')
    expect { @info.format = nil }.to raise_error(TypeError)
  end

  def test_fuzz
    expect { @info.fuzz = 50 }.not_to raise_error
    expect(@info.fuzz).to eq(50)
    expect { @info.fuzz = '50%' }.not_to raise_error
    expect(@info.fuzz).to eq(Magick::QuantumRange * 0.5)
    expect { @info.fuzz = nil }.to raise_error(TypeError)
    expect { @info.fuzz = 'xxx' }.to raise_error(ArgumentError)
  end

  def test_gravity
    Magick::GravityType.values.each do |v|
      expect { @info.gravity = v }.not_to raise_error
      expect(@info.gravity).to eq(v)
    end
    expect { @info.gravity = nil }.not_to raise_error
  end

  def test_image_type
    Magick::ImageType.values.each do |v|
      expect { @info.image_type = v }.not_to raise_error
      expect(@info.image_type).to eq(v)
    end
    expect { @info.image_type = nil }.to raise_error(TypeError)
  end

  def test_interlace
    Magick::InterlaceType.values.each do |v|
      expect { @info.interlace = v }.not_to raise_error
      expect(@info.interlace).to eq(v)
    end
    expect { @info.interlace = nil }.to raise_error(TypeError)
  end

  def test_label
    expect { @info.label = 'string' }.not_to raise_error
    expect(@info.label).to eq('string')
    expect { @info.label = nil }.not_to raise_error
    expect(@info.label).to be(nil)
  end

  def test_matte_color
    expect { @info.matte_color = 'red' }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { @info.matte_color = red }.not_to raise_error
    expect(@info.matte_color).to eq('red')
    img = Magick::Image.new(20, 20) { self.matte_color = 'red' }
    expect(img.matte_color).to eq('red')
    expect { @info.matte_color = nil }.to raise_error(TypeError)
  end

  def test_monitor
    expect { @info.monitor = -> {} }.not_to raise_error
    monitor = proc do |mth, q, s|
      expect(mth).to eq('resize!')
      expect(q).to be_kind_of(Integer)
      expect(s).to be_kind_of(Integer)
      GC.start
      true
    end
    img = Magick::Image.new(2000, 2000) { self.monitor = monitor }
    img.resize!(20, 20)
    img.monitor = nil

    expect { @info.monitor = nil }.not_to raise_error
  end

  def test_monochrome
    expect { @info.monochrome = true }.not_to raise_error
    expect(@info.monochrome).to be(true)
    expect { @info.monochrome = nil }.not_to raise_error
  end

  def test_number_scenes
    expect(@info.number_scenes).to be_kind_of(Integer)
    expect { @info.number_scenes = 50 }.not_to raise_error
    expect(@info.number_scenes).to eq(50)
    expect { @info.number_scenes = nil }.to raise_error(TypeError)
    expect { @info.number_scenes = 'xxx' }.to raise_error(TypeError)
  end

  def test_orientation
    Magick::OrientationType.values.each do |v|
      expect { @info.orientation = v }.not_to raise_error
      expect(@info.orientation).to eq(v)
    end
    expect { @info.orientation = nil }.to raise_error(TypeError)
  end

  def test_origin
    expect { @info.origin = '+10+10' }.not_to raise_error
    expect(@info.origin).to eq('+10+10')
    expect { @info.origin = Magick::Geometry.new(nil, nil, 10, 10) }.not_to raise_error
    expect(@info.origin).to eq('+10+10')
    expect { @info.origin = nil }.not_to raise_error
    expect(@info.origin).to be(nil)
    expect { @info.origin = 'aaa' }.to raise_error(ArgumentError)
  end

  def test_page
    expect { @info.page = '612x792>' }.not_to raise_error
    expect(@info.page).to eq('612x792>')
    expect { @info.page = nil }.not_to raise_error
    expect(@info.page).to be(nil)
  end

  def test_pointsize
    expect { @info.pointsize = 12 }.not_to raise_error
    expect(@info.pointsize).to eq(12)
  end

  def test_quality
    expect { @info.quality = 75 }.not_to raise_error
    expect(@info.quality).to eq(75)
  end

  def test_sampling_factor
    expect { @info.sampling_factor = '2x1' }.not_to raise_error
    expect(@info.sampling_factor).to eq('2x1')
    expect { @info.sampling_factor = nil }.not_to raise_error
    expect(@info.sampling_factor).to be(nil)
  end

  def test_scene
    expect { @info.scene = 123 }.not_to raise_error
    expect(@info.scene).to eq(123)
    expect { @info.scene = 'xxx' }.to raise_error(TypeError)
  end

  def test_server_name
    expect { @info.server_name = 'foo' }.not_to raise_error
    expect(@info.server_name).to eq('foo')
    expect { @info.server_name = nil }.not_to raise_error
    expect(@info.server_name).to be(nil)
  end

  def test_size
    expect { @info.size = '200x100' }.not_to raise_error
    expect(@info.size).to eq('200x100')
    expect { @info.size = Magick::Geometry.new(100, 200) }.not_to raise_error
    expect(@info.size).to eq('100x200')
    expect { @info.size = nil }.not_to raise_error
    expect(@info.size).to be(nil)
    expect { @info.size = 'aaa' }.to raise_error(ArgumentError)
  end

  def test_stroke
    expect { @info.stroke }.not_to raise_error
    expect(@info.stroke).to be(nil)

    expect { @info.stroke = 'white' }.not_to raise_error
    expect(@info.stroke).to eq('white')

    expect { @info.stroke = nil }.not_to raise_error
    expect(@info.stroke).to be(nil)

    expect { @info.stroke = 'xxx' }.to raise_error(ArgumentError)
  end

  def test_stroke_width
    expect { @info.stroke_width = 10 }.not_to raise_error
    expect(@info.stroke_width).to eq(10)
    expect { @info.stroke_width = 5.25 }.not_to raise_error
    expect(@info.stroke_width).to eq(5.25)
    expect { @info.stroke_width = nil }.not_to raise_error
    expect(@info.stroke_width).to be(nil)
    expect { @info.stroke_width = 'xxx' }.to raise_error(TypeError)
  end

  def test_texture
    img = Magick::Image.read('granite:') { self.size = '20x20' }
    expect { @info.texture = img.first }.not_to raise_error
    expect { @info.texture = nil }.not_to raise_error
  end

  def test_tile_offset
    expect { @info.tile_offset = '200x100' }.not_to raise_error
    expect(@info.tile_offset).to eq('200x100')
    expect { @info.tile_offset = Magick::Geometry.new(100, 200) }.not_to raise_error
    expect(@info.tile_offset).to eq('100x200')
    expect { @info.tile_offset = nil }.to raise_error(ArgumentError)
  end

  def test_transparent_color
    expect { @info.transparent_color = 'white' }.not_to raise_error
    expect(@info.transparent_color).to eq('white')
    expect { @info.transparent_color = nil }.to raise_error(TypeError)
  end

  def test_undercolor
    expect { @info.undercolor }.not_to raise_error
    expect(@info.undercolor).to be(nil)

    expect { @info.undercolor = 'white' }.not_to raise_error
    expect(@info.undercolor).to eq('white')

    expect { @info.undercolor = nil }.not_to raise_error
    expect(@info.undercolor).to be(nil)

    expect { @info.undercolor = 'xxx' }.to raise_error(ArgumentError)
  end

  def test_units
    Magick::ResolutionType.values.each do |v|
      expect { @info.units = v }.not_to raise_error
      expect(@info.units).to eq(v)
    end
  end

  def test_view
    expect { @info.view = 'string' }.not_to raise_error
    expect(@info.view).to eq('string')
    expect { @info.view = nil }.not_to raise_error
    expect(@info.view).to be(nil)
    expect { @info.view = '' }.not_to raise_error
    expect(@info.view).to eq('')
  end
end
