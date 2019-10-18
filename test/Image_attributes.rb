require 'fileutils'
require 'rmagick'
require 'minitest/autorun'

# TODO
#   test frozen attributes!
#   improve test_directory
#   improve test_montage

class Image_Attributes_UT < Minitest::Test
  def setup
    @img = Magick::Image.new(100, 100)
    gc = Magick::Draw.new

    gc.stroke_width(5)
    gc.circle(50, 50, 80, 80)
    gc.draw(@img)

    @hat = Magick::Image.read(FLOWER_HAT).first
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  def test_background_color
    assert_nothing_raised { @img.background_color }
    expect(@img.background_color).to eq('white')
    assert_nothing_raised { @img.background_color = '#dfdfdf' }
    # expect(@img.background_color).to eq("rgb(223,223,223)")
    background_color = @img.background_color
    if background_color.length == 13
      expect(background_color).to eq('#DFDFDFDFDFDF')
    else
      expect(background_color).to eq('#DFDFDFDFDFDFFFFF')
    end
    assert_nothing_raised { @img.background_color = Magick::Pixel.new(Magick::QuantumRange, Magick::QuantumRange / 2.0, Magick::QuantumRange / 2.0) }
    # expect(@img.background_color).to eq("rgb(100%,49.9992%,49.9992%)")
    background_color = @img.background_color
    if background_color.length == 13
      expect(background_color).to eq('#FFFF7FFF7FFF')
    else
      expect(background_color).to eq('#FFFF7FFF7FFFFFFF')
    end
    assert_raise(TypeError) { @img.background_color = 2 }
  end

  def test_base_columns
    assert_nothing_raised { @img.base_columns }
    expect(@img.base_columns).to eq(0)
    assert_raise(NoMethodError) { @img.base_columns = 1 }
  end

  def test_base_filename
    assert_nothing_raised { @img.base_filename }
    expect(@img.base_filename).to eq('')
    assert_raise(NoMethodError) { @img.base_filename = 'xxx' }
  end

  def test_base_rows
    assert_nothing_raised { @img.base_rows }
    expect(@img.base_rows).to eq(0)
    assert_raise(NoMethodError) { @img.base_rows = 1 }
  end

  def test_bias
    assert_nothing_raised { @img.bias }
    expect(@img.bias).to eq(0.0)
    assert_instance_of(Float, @img.bias)

    assert_nothing_raised { @img.bias = 0.1 }
    assert_in_delta(Magick::QuantumRange * 0.1, @img.bias, 0.1)

    assert_nothing_raised { @img.bias = '10%' }
    assert_in_delta(Magick::QuantumRange * 0.10, @img.bias, 0.1)

    assert_raise(TypeError) { @img.bias = [] }
    assert_raise(ArgumentError) { @img.bias = 'x' }
  end

  def test_black_point_compensation
    assert_nothing_raised { @img.black_point_compensation = true }
    assert(@img.black_point_compensation)
    assert_nothing_raised { @img.black_point_compensation = false }
    expect(@img.black_point_compensation).to eq(false)
  end

  def test_border_color
    assert_nothing_raised { @img.border_color }
    # expect(@img.border_color).to eq("rgb(223,223,223)")
    border_color = @img.border_color
    if border_color.length == 13
      expect(border_color).to eq('#DFDFDFDFDFDF')
    else
      expect(border_color).to eq('#DFDFDFDFDFDFFFFF')
    end
    assert_nothing_raised { @img.border_color = 'red' }
    expect(@img.border_color).to eq('red')
    assert_nothing_raised { @img.border_color = Magick::Pixel.new(Magick::QuantumRange, Magick::QuantumRange / 2, Magick::QuantumRange / 2) }
    # expect(@img.border_color).to eq("rgb(100%,49.9992%,49.9992%)")
    border_color = @img.border_color
    if border_color.length == 13
      expect(border_color).to eq('#FFFF7FFF7FFF')
    else
      expect(border_color).to eq('#FFFF7FFF7FFFFFFF')
    end
    assert_raise(TypeError) { @img.border_color = 2 }
  end

  def test_bounding_box
    assert_nothing_raised { @img.bounding_box }
    box = @img.bounding_box
    expect(box.width).to eq(87)
    expect(box.height).to eq(87)
    expect(box.x).to eq(7)
    expect(box.y).to eq(7)
    assert_raise(NoMethodError) { @img.bounding_box = 2 }
  end

  def test_chromaticity
    chrom = @img.chromaticity
    assert_nothing_raised { @img.chromaticity }
    assert_instance_of(Magick::Chromaticity, chrom)
    expect(chrom.red_primary.x).to eq(0)
    expect(chrom.red_primary.y).to eq(0)
    expect(chrom.red_primary.z).to eq(0)
    expect(chrom.green_primary.x).to eq(0)
    expect(chrom.green_primary.y).to eq(0)
    expect(chrom.green_primary.z).to eq(0)
    expect(chrom.blue_primary.x).to eq(0)
    expect(chrom.blue_primary.y).to eq(0)
    expect(chrom.blue_primary.z).to eq(0)
    expect(chrom.white_point.x).to eq(0)
    expect(chrom.white_point.y).to eq(0)
    expect(chrom.white_point.z).to eq(0)
    assert_nothing_raised { @img.chromaticity = chrom }
    assert_raise(TypeError) { @img.chromaticity = 2 }
  end

  def test_class_type
    assert_nothing_raised { @img.class_type }
    assert_instance_of(Magick::ClassType, @img.class_type)
    expect(@img.class_type).to eq(Magick::DirectClass)
    assert_nothing_raised { @img.class_type = Magick::PseudoClass }
    expect(@img.class_type).to eq(Magick::PseudoClass)
    assert_raise(TypeError) { @img.class_type = 2 }

    assert_nothing_raised do
      @img.class_type = Magick::PseudoClass
      @img.class_type = Magick::DirectClass
      expect(@img.class_type).to eq(Magick::DirectClass)
    end
  end

  def test_color_profile
    assert_nothing_raised { @img.color_profile }
    assert_nil(@img.color_profile)
    assert_nothing_raised { @img.color_profile = @p }
    expect(@img.color_profile).to eq(@p)
    assert_raise(TypeError) { @img.color_profile = 2 }
  end

  def test_colors
    assert_nothing_raised { @img.colors }
    expect(@img.colors).to eq(0)
    img = @img.copy
    img.class_type = Magick::PseudoClass
    assert_kind_of(Integer, img.colors)
    assert_raise(NoMethodError) { img.colors = 2 }
  end

  def test_colorspace
    assert_nothing_raised { @img.colorspace }
    assert_instance_of(Magick::ColorspaceType, @img.colorspace)
    expect(@img.colorspace).to eq(Magick::SRGBColorspace)
    img = @img.copy

    Magick::ColorspaceType.values do |colorspace|
      assert_nothing_raised { img.colorspace = colorspace }
    end
    assert_raise(TypeError) { @img.colorspace = 2 }
    Magick::ColorspaceType.values.each do |cs|
      assert_nothing_raised { img.colorspace = cs }
    end
  end

  def test_columns
    assert_nothing_raised { @img.columns }
    expect(@img.columns).to eq(100)
    assert_raise(NoMethodError) { @img.columns = 2 }
  end

  def test_compose
    assert_nothing_raised { @img.compose }
    assert_instance_of(Magick::CompositeOperator, @img.compose)
    expect(@img.compose).to eq(Magick::OverCompositeOp)
    assert_raise(TypeError) { @img.compose = 2 }
    assert_nothing_raised { @img.compose = Magick::UndefinedCompositeOp }
    expect(@img.compose).to eq(Magick::UndefinedCompositeOp)

    Magick::CompositeOperator.values do |composite|
      assert_nothing_raised { @img.compose = composite }
    end
    assert_raise(TypeError) { @img.compose = 2 }
  end

  def test_compression
    assert_nothing_raised { @img.compression }
    assert_instance_of(Magick::CompressionType, @img.compression)
    expect(@img.compression).to eq(Magick::UndefinedCompression)
    assert_nothing_raised { @img.compression = Magick::BZipCompression }
    expect(@img.compression).to eq(Magick::BZipCompression)

    Magick::CompressionType.values do |compression|
      assert_nothing_raised { @img.compression = compression }
    end
    assert_raise(TypeError) { @img.compression = 2 }
  end

  def test_delay
    assert_nothing_raised { @img.delay }
    expect(@img.delay).to eq(0)
    assert_nothing_raised { @img.delay = 10 }
    expect(@img.delay).to eq(10)
    assert_raise(TypeError) { @img.delay = 'x' }
  end

  def test_density
    assert_nothing_raised { @img.density }
    assert_nothing_raised { @img.density = '90x90' }
    assert_nothing_raised { @img.density = 'x90' }
    assert_nothing_raised { @img.density = '90' }
    assert_nothing_raised { @img.density = Magick::Geometry.new(@img.columns / 2, @img.rows / 2, 5, 5) }
    assert_raise(TypeError) { @img.density = 2 }
  end

  def test_depth
    expect(@img.depth).to eq(Magick::MAGICKCORE_QUANTUM_DEPTH)
    assert_raise(NoMethodError) { @img.depth = 2 }
  end

  def test_directory
    assert_nothing_raised { @img.directory }
    assert_nil(@img.directory)
    assert_raise(NoMethodError) { @img.directory = nil }
  end

  def test_dispose
    assert_nothing_raised { @img.dispose }
    assert_instance_of(Magick::DisposeType, @img.dispose)
    expect(@img.dispose).to eq(Magick::UndefinedDispose)
    assert_nothing_raised { @img.dispose = Magick::NoneDispose }
    expect(@img.dispose).to eq(Magick::NoneDispose)

    Magick::DisposeType.values do |dispose|
      assert_nothing_raised { @img.dispose = dispose }
    end
    assert_raise(TypeError) { @img.dispose = 2 }
  end

  def test_endian
    assert_nothing_raised { @img.endian }
    assert_instance_of(Magick::EndianType, @img.endian)
    expect(@img.endian).to eq(Magick::UndefinedEndian)
    assert_nothing_raised { @img.endian = Magick::LSBEndian }
    expect(@img.endian).to eq(Magick::LSBEndian)
    assert_nothing_raised { @img.endian = Magick::MSBEndian }
    assert_raise(TypeError) { @img.endian = 2 }
  end

  def test_extract_info
    assert_nothing_raised { @img.extract_info }
    assert_instance_of(Magick::Rectangle, @img.extract_info)
    ext = @img.extract_info
    expect(ext.x).to eq(0)
    expect(ext.y).to eq(0)
    expect(ext.width).to eq(0)
    expect(ext.height).to eq(0)
    ext = Magick::Rectangle.new(1, 2, 3, 4)
    assert_nothing_raised { @img.extract_info = ext }
    expect(ext.width).to eq(1)
    expect(ext.height).to eq(2)
    expect(ext.x).to eq(3)
    expect(ext.y).to eq(4)
    assert_raise(TypeError) { @img.extract_info = 2 }
  end

  def test_filename
    assert_nothing_raised { @img.filename }
    expect(@img.filename).to eq('')
    assert_raises(NoMethodError) { @img.filename = 'xxx' }
  end

  def test_filter
    assert_nothing_raised { @img.filter }
    assert_instance_of(Magick::FilterType, @img.filter)
    expect(@img.filter).to eq(Magick::UndefinedFilter)
    assert_nothing_raised { @img.filter = Magick::PointFilter }
    expect(@img.filter).to eq(Magick::PointFilter)

    Magick::FilterType.values do |filter|
      assert_nothing_raised { @img.filter = filter }
    end
    assert_raise(TypeError) { @img.filter = 2 }
  end

  def test_format
    assert_nothing_raised { @img.format }
    assert_nil(@img.format)
    assert_nothing_raised { @img.format = 'GIF' }
    assert_nothing_raised { @img.format = 'JPG' }
    assert_nothing_raised { @img.format = 'TIFF' }
    assert_nothing_raised { @img.format = 'MIFF' }
    assert_nothing_raised { @img.format = 'MPEG' }
    v = $VERBOSE
    $VERBOSE = nil
    assert_raise(ArgumentError) { @img.format = 'shit' }
    $VERBOSE = v
    assert_raise(TypeError) { @img.format = 2 }
  end

  def test_fuzz
    assert_nothing_raised { @img.fuzz }
    assert_instance_of(Float, @img.fuzz)
    expect(@img.fuzz).to eq(0.0)
    assert_nothing_raised { @img.fuzz = 50 }
    expect(@img.fuzz).to eq(50.0)
    assert_nothing_raised { @img.fuzz = '50%' }
    assert_in_delta(Magick::QuantumRange * 0.50, @img.fuzz, 0.1)
    assert_raise(TypeError) { @img.fuzz = [] }
    assert_raise(ArgumentError) { @img.fuzz = 'xxx' }
  end

  def test_gamma
    assert_nothing_raised { @img.gamma }
    assert_instance_of(Float, @img.gamma)
    expect(@img.gamma).to eq(0.45454543828964233)
    assert_nothing_raised { @img.gamma = 2.0 }
    expect(@img.gamma).to eq(2.0)
    assert_raise(TypeError) { @img.gamma = 'x' }
  end

  def test_geometry
    assert_nothing_raised { @img.geometry }
    assert_nil(@img.geometry)
    assert_nothing_raised { @img.geometry = nil }
    assert_nothing_raised { @img.geometry = '90x90' }
    expect(@img.geometry).to eq('90x90')
    assert_nothing_raised { @img.geometry = Magick::Geometry.new(100, 80) }
    expect(@img.geometry).to eq('100x80')
    assert_raise(TypeError) { @img.geometry = [] }
  end

  def test_gravity
    assert_instance_of(Magick::GravityType, @img.gravity)

    Magick::GravityType.values do |gravity|
      assert_nothing_raised { @img.gravity = gravity }
    end
    assert_raise(TypeError) { @img.gravity = nil }
    assert_raise(TypeError) { @img.gravity = Magick::PointFilter }
  end

  def test_image_type
    assert_instance_of(Magick::ImageType, @img.image_type)

    Magick::ImageType.values do |image_type|
      assert_nothing_raised { @img.image_type = image_type }
    end
    assert_raise(TypeError) { @img.image_type = nil }
    assert_raise(TypeError) { @img.image_type = Magick::PointFilter }
  end

  def test_interlace_type
    assert_nothing_raised { @img.interlace }
    assert_instance_of(Magick::InterlaceType, @img.interlace)
    expect(@img.interlace).to eq(Magick::NoInterlace)
    assert_nothing_raised { @img.interlace = Magick::LineInterlace }
    expect(@img.interlace).to eq(Magick::LineInterlace)

    Magick::InterlaceType.values do |interlace|
      assert_nothing_raised { @img.interlace = interlace }
    end
    assert_raise(TypeError) { @img.interlace = 2 }
  end

  def test_iptc_profile
    assert_nothing_raised { @img.iptc_profile }
    assert_nil(@img.iptc_profile)
    assert_nothing_raised { @img.iptc_profile = 'xxx' }
    expect(@img.iptc_profile).to eq('xxx')
    assert_raise(TypeError) { @img.iptc_profile = 2 }
  end

  def test_mean_error
    assert_nothing_raised { @hat.mean_error_per_pixel }
    assert_nothing_raised { @hat.normalized_mean_error }
    assert_nothing_raised { @hat.normalized_maximum_error }
    expect(@hat.mean_error_per_pixel).to eq(0.0)
    expect(@hat.normalized_mean_error).to eq(0.0)
    expect(@hat.normalized_maximum_error).to eq(0.0)

    hat = @hat.quantize(16, Magick::RGBColorspace, true, 0, true)

    assert_not_equal(0.0, hat.mean_error_per_pixel)
    assert_not_equal(0.0, hat.normalized_mean_error)
    assert_not_equal(0.0, hat.normalized_maximum_error)
    assert_raise(NoMethodError) { hat.mean_error_per_pixel = 1 }
    assert_raise(NoMethodError) { hat.normalized_mean_error = 1 }
    assert_raise(NoMethodError) { hat.normalized_maximum_error = 1 }
  end

  def test_mime_type
    img = @img.copy
    img.format = 'GIF'
    assert_nothing_raised { img.mime_type }
    expect(img.mime_type).to eq('image/gif')
    img.format = 'JPG'
    expect(img.mime_type).to eq('image/jpeg')
    assert_raise(NoMethodError) { img.mime_type = 'image/jpeg' }
  end

  def test_monitor
    assert_raise(NoMethodError) { @img.monitor }
    monitor = proc { |name, _q, _s| puts name }
    assert_nothing_raised { @img.monitor = monitor }
    assert_nothing_raised { @img.monitor = nil }
  end

  def test_montage
    assert_nothing_raised { @img.montage }
    assert_nil(@img.montage)
  end

  def test_number_colors
    assert_nothing_raised { @hat.number_colors }
    assert_kind_of(Integer, @hat.number_colors)
    assert_raise(NoMethodError) { @hat.number_colors = 2 }
  end

  def test_offset
    assert_nothing_raised { @img.offset }
    expect(@img.offset).to eq(0)
    assert_nothing_raised { @img.offset = 10 }
    expect(@img.offset).to eq(10)
    assert_raise(TypeError) { @img.offset = 'x' }
  end

  def test_orientation
    assert_nothing_raised { @img.orientation }
    assert_instance_of(Magick::OrientationType, @img.orientation)
    expect(@img.orientation).to eq(Magick::UndefinedOrientation)
    assert_nothing_raised { @img.orientation = Magick::TopLeftOrientation }
    expect(@img.orientation).to eq(Magick::TopLeftOrientation)

    Magick::OrientationType.values do |orientation|
      assert_nothing_raised { @img.orientation = orientation }
    end
    assert_raise(TypeError) { @img.orientation = 2 }
  end

  def test_page
    assert_nothing_raised { @img.page }
    page = @img.page
    expect(page.width).to eq(0)
    expect(page.height).to eq(0)
    expect(page.x).to eq(0)
    expect(page.y).to eq(0)
    page = Magick::Rectangle.new(1, 2, 3, 4)
    assert_nothing_raised { @img.page = page }
    expect(page.width).to eq(1)
    expect(page.height).to eq(2)
    expect(page.x).to eq(3)
    expect(page.y).to eq(4)
    assert_raise(TypeError) { @img.page = 2 }
  end

  def test_pixel_interpolation_method
    assert_nothing_raised { @img.pixel_interpolation_method }
    assert_instance_of(Magick::PixelInterpolateMethod, @img.pixel_interpolation_method)
    expect(@img.pixel_interpolation_method).to eq(Magick::UndefinedInterpolatePixel)
    assert_nothing_raised { @img.pixel_interpolation_method = Magick::AverageInterpolatePixel }
    expect(@img.pixel_interpolation_method).to eq(Magick::AverageInterpolatePixel)

    Magick::PixelInterpolateMethod.values do |interpolate_pixel_method|
      assert_nothing_raised { @img.pixel_interpolation_method = interpolate_pixel_method }
    end
    assert_raise(TypeError) { @img.pixel_interpolation_method = 2 }
  end

  def test_quality
    assert_nothing_raised { @hat.quality }
    expect(@hat.quality).to eq(75)
    assert_raise(NoMethodError) { @img.quality = 80 }
  end

  def test_quantum_depth
    assert_nothing_raised { @img.quantum_depth }
    expect(@img.quantum_depth).to eq(Magick::MAGICKCORE_QUANTUM_DEPTH)
    assert_raise(NoMethodError) { @img.quantum_depth = 8 }
  end

  def test_rendering_intent
    assert_nothing_raised { @img.rendering_intent }
    assert_instance_of(Magick::RenderingIntent, @img.rendering_intent)
    expect(@img.rendering_intent).to eq(Magick::PerceptualIntent)

    Magick::RenderingIntent.values do |rendering_intent|
      assert_nothing_raised { @img.rendering_intent = rendering_intent }
    end
    assert_raise(TypeError) { @img.rendering_intent = 2 }
  end

  def test_rows
    assert_nothing_raised { @img.rows }
    expect(@img.rows).to eq(100)
    assert_raise(NoMethodError) { @img.rows = 2 }
  end

  def test_scene
    ilist = Magick::ImageList.new
    ilist << @img
    img = @img.copy
    ilist << img
    ilist.write('temp.gif')
    FileUtils.rm('temp.gif')

    assert_nothing_raised { img.scene }
    expect(@img.scene).to eq(0)
    expect(img.scene).to eq(1)
    assert_raise(NoMethodError) { img.scene = 2 }
  end

  def test_start_loop
    assert_nothing_raised { @img.start_loop }
    assert(!@img.start_loop)
    assert_nothing_raised { @img.start_loop = true }
    assert(@img.start_loop)
  end

  def test_ticks_per_second
    assert_nothing_raised { @img.ticks_per_second }
    expect(@img.ticks_per_second).to eq(100)
    assert_nothing_raised { @img.ticks_per_second = 1000 }
    expect(@img.ticks_per_second).to eq(1000)
    assert_raise(TypeError) { @img.ticks_per_second = 'x' }
  end

  def test_total_colors
    assert_nothing_raised { @hat.total_colors }
    assert_kind_of(Integer, @hat.total_colors)
    assert_raise(NoMethodError) { @img.total_colors = 2 }
  end

  def test_units
    assert_nothing_raised { @img.units }
    assert_instance_of(Magick::ResolutionType, @img.units)
    expect(@img.units).to eq(Magick::UndefinedResolution)
    assert_nothing_raised { @img.units = Magick::PixelsPerInchResolution }
    expect(@img.units).to eq(Magick::PixelsPerInchResolution)

    Magick::ResolutionType.values do |resolution|
      assert_nothing_raised { @img.units = resolution }
    end
    assert_raise(TypeError) { @img.units = 2 }
  end

  def test_virtual_pixel_method
    assert_nothing_raised { @img.virtual_pixel_method }
    expect(@img.virtual_pixel_method).to eq(Magick::UndefinedVirtualPixelMethod)
    assert_nothing_raised { @img.virtual_pixel_method = Magick::EdgeVirtualPixelMethod }
    expect(@img.virtual_pixel_method).to eq(Magick::EdgeVirtualPixelMethod)

    Magick::VirtualPixelMethod.values do |virtual_pixel_method|
      assert_nothing_raised { @img.virtual_pixel_method = virtual_pixel_method }
    end
    assert_raise(TypeError) { @img.virtual_pixel_method = 2 }
  end

  def test_x_resolution
    assert_nothing_raised { @img.x_resolution }
    assert_nothing_raised { @img.x_resolution = 90 }
    expect(@img.x_resolution).to eq(90.0)
    assert_raise(TypeError) { @img.x_resolution = 'x' }
  end

  def test_y_resolution
    assert_nothing_raised { @img.y_resolution }
    assert_nothing_raised { @img.y_resolution = 90 }
    expect(@img.y_resolution).to eq(90.0)
    assert_raise(TypeError) { @img.y_resolution = 'x' }
  end

  def test_frozen
    @img.freeze
    assert_raise(FreezeError) { @img.background_color = 'xxx' }
    assert_raise(FreezeError) { @img.border_color = 'xxx' }
    rp = Magick::Point.new(1, 1)
    gp = Magick::Point.new(1, 1)
    bp = Magick::Point.new(1, 1)
    wp = Magick::Point.new(1, 1)
    assert_raise(FreezeError) { @img.chromaticity = Magick::Chromaticity.new(rp, gp, bp, wp) }
    assert_raise(FreezeError) { @img.class_type = Magick::DirectClass }
    assert_raise(FreezeError) { @img.color_profile = 'xxx' }
    assert_raise(FreezeError) { @img.colorspace = Magick::RGBColorspace }
    assert_raise(FreezeError) { @img.compose = Magick::OverCompositeOp }
    assert_raise(FreezeError) { @img.compression = Magick::RLECompression }
    assert_raise(FreezeError) { @img.delay = 2 }
    assert_raise(FreezeError) { @img.density = '72.0x72.0' }
    assert_raise(FreezeError) { @img.dispose = Magick::NoneDispose }
    assert_raise(FreezeError) { @img.endian = Magick::MSBEndian }
    assert_raise(FreezeError) { @img.extract_info = Magick::Rectangle.new(1, 2, 3, 4) }
    assert_raise(FreezeError) { @img.filter = Magick::PointFilter }
    assert_raise(FreezeError) { @img.format = 'GIF' }
    assert_raise(FreezeError) { @img.fuzz = 50.0 }
    assert_raise(FreezeError) { @img.gamma = 2.0 }
    assert_raise(FreezeError) { @img.geometry = '100x100' }
    assert_raise(FreezeError) { @img.interlace = Magick::NoInterlace }
    assert_raise(FreezeError) { @img.iptc_profile = 'xxx' }
    assert_raise(FreezeError) { @img.monitor = proc { |name, _q, _s| puts name } }
    assert_raise(FreezeError) { @img.offset = 100 }
    assert_raise(FreezeError) { @img.page = Magick::Rectangle.new(1, 2, 3, 4) }
    assert_raise(FreezeError) { @img.rendering_intent = Magick::SaturationIntent }
    assert_raise(FreezeError) { @img.start_loop = true }
    assert_raise(FreezeError) { @img.ticks_per_second = 1000 }
    assert_raise(FreezeError) { @img.units = Magick::PixelsPerInchResolution }
    assert_raise(FreezeError) { @img.x_resolution = 72.0 }
    assert_raise(FreezeError) { @img.y_resolution = 72.0 }
  end
end # class Image_Attributes_UT

if $PROGRAM_NAME == __FILE__
  FLOWER_HAT = '../doc/ex/images/Flower_Hat.jpg'
  Test::Unit::UI::Console::TestRunner.run(ImageAttributesUT)
end
