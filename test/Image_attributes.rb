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
    expect { @img.background_color }.not_to raise_error
    expect(@img.background_color).to eq('white')
    expect { @img.background_color = '#dfdfdf' }.not_to raise_error
    # expect(@img.background_color).to eq("rgb(223,223,223)")
    background_color = @img.background_color
    if background_color.length == 13
      expect(background_color).to eq('#DFDFDFDFDFDF')
    else
      expect(background_color).to eq('#DFDFDFDFDFDFFFFF')
    end
    expect { @img.background_color = Magick::Pixel.new(Magick::QuantumRange, Magick::QuantumRange / 2.0, Magick::QuantumRange / 2.0) }.not_to raise_error
    # expect(@img.background_color).to eq("rgb(100%,49.9992%,49.9992%)")
    background_color = @img.background_color
    if background_color.length == 13
      expect(background_color).to eq('#FFFF7FFF7FFF')
    else
      expect(background_color).to eq('#FFFF7FFF7FFFFFFF')
    end
    expect { @img.background_color = 2 }.to raise_error(TypeError)
  end

  def test_base_columns
    expect { @img.base_columns }.not_to raise_error
    expect(@img.base_columns).to eq(0)
    expect { @img.base_columns = 1 }.to raise_error(NoMethodError)
  end

  def test_base_filename
    expect { @img.base_filename }.not_to raise_error
    expect(@img.base_filename).to eq('')
    expect { @img.base_filename = 'xxx' }.to raise_error(NoMethodError)
  end

  def test_base_rows
    expect { @img.base_rows }.not_to raise_error
    expect(@img.base_rows).to eq(0)
    expect { @img.base_rows = 1 }.to raise_error(NoMethodError)
  end

  def test_bias
    expect { @img.bias }.not_to raise_error
    expect(@img.bias).to eq(0.0)
    assert_instance_of(Float, @img.bias)

    expect { @img.bias = 0.1 }.not_to raise_error
    assert_in_delta(Magick::QuantumRange * 0.1, @img.bias, 0.1)

    expect { @img.bias = '10%' }.not_to raise_error
    assert_in_delta(Magick::QuantumRange * 0.10, @img.bias, 0.1)

    expect { @img.bias = [] }.to raise_error(TypeError)
    expect { @img.bias = 'x' }.to raise_error(ArgumentError)
  end

  def test_black_point_compensation
    expect { @img.black_point_compensation = true }.not_to raise_error
    assert(@img.black_point_compensation)
    expect { @img.black_point_compensation = false }.not_to raise_error
    expect(@img.black_point_compensation).to eq(false)
  end

  def test_border_color
    expect { @img.border_color }.not_to raise_error
    # expect(@img.border_color).to eq("rgb(223,223,223)")
    border_color = @img.border_color
    if border_color.length == 13
      expect(border_color).to eq('#DFDFDFDFDFDF')
    else
      expect(border_color).to eq('#DFDFDFDFDFDFFFFF')
    end
    expect { @img.border_color = 'red' }.not_to raise_error
    expect(@img.border_color).to eq('red')
    expect { @img.border_color = Magick::Pixel.new(Magick::QuantumRange, Magick::QuantumRange / 2, Magick::QuantumRange / 2) }.not_to raise_error
    # expect(@img.border_color).to eq("rgb(100%,49.9992%,49.9992%)")
    border_color = @img.border_color
    if border_color.length == 13
      expect(border_color).to eq('#FFFF7FFF7FFF')
    else
      expect(border_color).to eq('#FFFF7FFF7FFFFFFF')
    end
    expect { @img.border_color = 2 }.to raise_error(TypeError)
  end

  def test_bounding_box
    expect { @img.bounding_box }.not_to raise_error
    box = @img.bounding_box
    expect(box.width).to eq(87)
    expect(box.height).to eq(87)
    expect(box.x).to eq(7)
    expect(box.y).to eq(7)
    expect { @img.bounding_box = 2 }.to raise_error(NoMethodError)
  end

  def test_chromaticity
    chrom = @img.chromaticity
    expect { @img.chromaticity }.not_to raise_error
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
    expect { @img.chromaticity = chrom }.not_to raise_error
    expect { @img.chromaticity = 2 }.to raise_error(TypeError)
  end

  def test_class_type
    expect { @img.class_type }.not_to raise_error
    assert_instance_of(Magick::ClassType, @img.class_type)
    expect(@img.class_type).to eq(Magick::DirectClass)
    expect { @img.class_type = Magick::PseudoClass }.not_to raise_error
    expect(@img.class_type).to eq(Magick::PseudoClass)
    expect { @img.class_type = 2 }.to raise_error(TypeError)

    expect do
      @img.class_type = Magick::PseudoClass
      @img.class_type = Magick::DirectClass
      expect(@img.class_type).to eq(Magick::DirectClass)
    end.not_to raise_error
  end

  def test_color_profile
    expect { @img.color_profile }.not_to raise_error
    assert_nil(@img.color_profile)
    expect { @img.color_profile = @p }.not_to raise_error
    expect(@img.color_profile).to eq(@p)
    expect { @img.color_profile = 2 }.to raise_error(TypeError)
  end

  def test_colors
    expect { @img.colors }.not_to raise_error
    expect(@img.colors).to eq(0)
    img = @img.copy
    img.class_type = Magick::PseudoClass
    assert_kind_of(Integer, img.colors)
    expect { img.colors = 2 }.to raise_error(NoMethodError)
  end

  def test_colorspace
    expect { @img.colorspace }.not_to raise_error
    assert_instance_of(Magick::ColorspaceType, @img.colorspace)
    expect(@img.colorspace).to eq(Magick::SRGBColorspace)
    img = @img.copy

    Magick::ColorspaceType.values do |colorspace|
      expect { img.colorspace = colorspace }.not_to raise_error
    end
    expect { @img.colorspace = 2 }.to raise_error(TypeError)
    Magick::ColorspaceType.values.each do |cs|
      expect { img.colorspace = cs }.not_to raise_error
    end
  end

  def test_columns
    expect { @img.columns }.not_to raise_error
    expect(@img.columns).to eq(100)
    expect { @img.columns = 2 }.to raise_error(NoMethodError)
  end

  def test_compose
    expect { @img.compose }.not_to raise_error
    assert_instance_of(Magick::CompositeOperator, @img.compose)
    expect(@img.compose).to eq(Magick::OverCompositeOp)
    expect { @img.compose = 2 }.to raise_error(TypeError)
    expect { @img.compose = Magick::UndefinedCompositeOp }.not_to raise_error
    expect(@img.compose).to eq(Magick::UndefinedCompositeOp)

    Magick::CompositeOperator.values do |composite|
      expect { @img.compose = composite }.not_to raise_error
    end
    expect { @img.compose = 2 }.to raise_error(TypeError)
  end

  def test_compression
    expect { @img.compression }.not_to raise_error
    assert_instance_of(Magick::CompressionType, @img.compression)
    expect(@img.compression).to eq(Magick::UndefinedCompression)
    expect { @img.compression = Magick::BZipCompression }.not_to raise_error
    expect(@img.compression).to eq(Magick::BZipCompression)

    Magick::CompressionType.values do |compression|
      expect { @img.compression = compression }.not_to raise_error
    end
    expect { @img.compression = 2 }.to raise_error(TypeError)
  end

  def test_delay
    expect { @img.delay }.not_to raise_error
    expect(@img.delay).to eq(0)
    expect { @img.delay = 10 }.not_to raise_error
    expect(@img.delay).to eq(10)
    expect { @img.delay = 'x' }.to raise_error(TypeError)
  end

  def test_density
    expect { @img.density }.not_to raise_error
    expect { @img.density = '90x90' }.not_to raise_error
    expect { @img.density = 'x90' }.not_to raise_error
    expect { @img.density = '90' }.not_to raise_error
    expect { @img.density = Magick::Geometry.new(@img.columns / 2, @img.rows / 2, 5, 5) }.not_to raise_error
    expect { @img.density = 2 }.to raise_error(TypeError)
  end

  def test_depth
    expect(@img.depth).to eq(Magick::MAGICKCORE_QUANTUM_DEPTH)
    expect { @img.depth = 2 }.to raise_error(NoMethodError)
  end

  def test_directory
    expect { @img.directory }.not_to raise_error
    assert_nil(@img.directory)
    expect { @img.directory = nil }.to raise_error(NoMethodError)
  end

  def test_dispose
    expect { @img.dispose }.not_to raise_error
    assert_instance_of(Magick::DisposeType, @img.dispose)
    expect(@img.dispose).to eq(Magick::UndefinedDispose)
    expect { @img.dispose = Magick::NoneDispose }.not_to raise_error
    expect(@img.dispose).to eq(Magick::NoneDispose)

    Magick::DisposeType.values do |dispose|
      expect { @img.dispose = dispose }.not_to raise_error
    end
    expect { @img.dispose = 2 }.to raise_error(TypeError)
  end

  def test_endian
    expect { @img.endian }.not_to raise_error
    assert_instance_of(Magick::EndianType, @img.endian)
    expect(@img.endian).to eq(Magick::UndefinedEndian)
    expect { @img.endian = Magick::LSBEndian }.not_to raise_error
    expect(@img.endian).to eq(Magick::LSBEndian)
    expect { @img.endian = Magick::MSBEndian }.not_to raise_error
    expect { @img.endian = 2 }.to raise_error(TypeError)
  end

  def test_extract_info
    expect { @img.extract_info }.not_to raise_error
    assert_instance_of(Magick::Rectangle, @img.extract_info)
    ext = @img.extract_info
    expect(ext.x).to eq(0)
    expect(ext.y).to eq(0)
    expect(ext.width).to eq(0)
    expect(ext.height).to eq(0)
    ext = Magick::Rectangle.new(1, 2, 3, 4)
    expect { @img.extract_info = ext }.not_to raise_error
    expect(ext.width).to eq(1)
    expect(ext.height).to eq(2)
    expect(ext.x).to eq(3)
    expect(ext.y).to eq(4)
    expect { @img.extract_info = 2 }.to raise_error(TypeError)
  end

  def test_filename
    expect { @img.filename }.not_to raise_error
    expect(@img.filename).to eq('')
    expect { @img.filename = 'xxx' }.to raise_error(NoMethodError)
  end

  def test_filter
    expect { @img.filter }.not_to raise_error
    assert_instance_of(Magick::FilterType, @img.filter)
    expect(@img.filter).to eq(Magick::UndefinedFilter)
    expect { @img.filter = Magick::PointFilter }.not_to raise_error
    expect(@img.filter).to eq(Magick::PointFilter)

    Magick::FilterType.values do |filter|
      expect { @img.filter = filter }.not_to raise_error
    end
    expect { @img.filter = 2 }.to raise_error(TypeError)
  end

  def test_format
    expect { @img.format }.not_to raise_error
    assert_nil(@img.format)
    expect { @img.format = 'GIF' }.not_to raise_error
    expect { @img.format = 'JPG' }.not_to raise_error
    expect { @img.format = 'TIFF' }.not_to raise_error
    expect { @img.format = 'MIFF' }.not_to raise_error
    expect { @img.format = 'MPEG' }.not_to raise_error
    v = $VERBOSE
    $VERBOSE = nil
    expect { @img.format = 'shit' }.to raise_error(ArgumentError)
    $VERBOSE = v
    expect { @img.format = 2 }.to raise_error(TypeError)
  end

  def test_fuzz
    expect { @img.fuzz }.not_to raise_error
    assert_instance_of(Float, @img.fuzz)
    expect(@img.fuzz).to eq(0.0)
    expect { @img.fuzz = 50 }.not_to raise_error
    expect(@img.fuzz).to eq(50.0)
    expect { @img.fuzz = '50%' }.not_to raise_error
    assert_in_delta(Magick::QuantumRange * 0.50, @img.fuzz, 0.1)
    expect { @img.fuzz = [] }.to raise_error(TypeError)
    expect { @img.fuzz = 'xxx' }.to raise_error(ArgumentError)
  end

  def test_gamma
    expect { @img.gamma }.not_to raise_error
    assert_instance_of(Float, @img.gamma)
    expect(@img.gamma).to eq(0.45454543828964233)
    expect { @img.gamma = 2.0 }.not_to raise_error
    expect(@img.gamma).to eq(2.0)
    expect { @img.gamma = 'x' }.to raise_error(TypeError)
  end

  def test_geometry
    expect { @img.geometry }.not_to raise_error
    assert_nil(@img.geometry)
    expect { @img.geometry = nil }.not_to raise_error
    expect { @img.geometry = '90x90' }.not_to raise_error
    expect(@img.geometry).to eq('90x90')
    expect { @img.geometry = Magick::Geometry.new(100, 80) }.not_to raise_error
    expect(@img.geometry).to eq('100x80')
    expect { @img.geometry = [] }.to raise_error(TypeError)
  end

  def test_gravity
    assert_instance_of(Magick::GravityType, @img.gravity)

    Magick::GravityType.values do |gravity|
      expect { @img.gravity = gravity }.not_to raise_error
    end
    expect { @img.gravity = nil }.to raise_error(TypeError)
    expect { @img.gravity = Magick::PointFilter }.to raise_error(TypeError)
  end

  def test_image_type
    assert_instance_of(Magick::ImageType, @img.image_type)

    Magick::ImageType.values do |image_type|
      expect { @img.image_type = image_type }.not_to raise_error
    end
    expect { @img.image_type = nil }.to raise_error(TypeError)
    expect { @img.image_type = Magick::PointFilter }.to raise_error(TypeError)
  end

  def test_interlace_type
    expect { @img.interlace }.not_to raise_error
    assert_instance_of(Magick::InterlaceType, @img.interlace)
    expect(@img.interlace).to eq(Magick::NoInterlace)
    expect { @img.interlace = Magick::LineInterlace }.not_to raise_error
    expect(@img.interlace).to eq(Magick::LineInterlace)

    Magick::InterlaceType.values do |interlace|
      expect { @img.interlace = interlace }.not_to raise_error
    end
    expect { @img.interlace = 2 }.to raise_error(TypeError)
  end

  def test_iptc_profile
    expect { @img.iptc_profile }.not_to raise_error
    assert_nil(@img.iptc_profile)
    expect { @img.iptc_profile = 'xxx' }.not_to raise_error
    expect(@img.iptc_profile).to eq('xxx')
    expect { @img.iptc_profile = 2 }.to raise_error(TypeError)
  end

  def test_mean_error
    expect { @hat.mean_error_per_pixel }.not_to raise_error
    expect { @hat.normalized_mean_error }.not_to raise_error
    expect { @hat.normalized_maximum_error }.not_to raise_error
    expect(@hat.mean_error_per_pixel).to eq(0.0)
    expect(@hat.normalized_mean_error).to eq(0.0)
    expect(@hat.normalized_maximum_error).to eq(0.0)

    hat = @hat.quantize(16, Magick::RGBColorspace, true, 0, true)

    assert_not_equal(0.0, hat.mean_error_per_pixel)
    assert_not_equal(0.0, hat.normalized_mean_error)
    assert_not_equal(0.0, hat.normalized_maximum_error)
    expect { hat.mean_error_per_pixel = 1 }.to raise_error(NoMethodError)
    expect { hat.normalized_mean_error = 1 }.to raise_error(NoMethodError)
    expect { hat.normalized_maximum_error = 1 }.to raise_error(NoMethodError)
  end

  def test_mime_type
    img = @img.copy
    img.format = 'GIF'
    expect { img.mime_type }.not_to raise_error
    expect(img.mime_type).to eq('image/gif')
    img.format = 'JPG'
    expect(img.mime_type).to eq('image/jpeg')
    expect { img.mime_type = 'image/jpeg' }.to raise_error(NoMethodError)
  end

  def test_monitor
    expect { @img.monitor }.to raise_error(NoMethodError)
    monitor = proc { |name, _q, _s| puts name }
    expect { @img.monitor = monitor }.not_to raise_error
    expect { @img.monitor = nil }.not_to raise_error
  end

  def test_montage
    expect { @img.montage }.not_to raise_error
    assert_nil(@img.montage)
  end

  def test_number_colors
    expect { @hat.number_colors }.not_to raise_error
    assert_kind_of(Integer, @hat.number_colors)
    expect { @hat.number_colors = 2 }.to raise_error(NoMethodError)
  end

  def test_offset
    expect { @img.offset }.not_to raise_error
    expect(@img.offset).to eq(0)
    expect { @img.offset = 10 }.not_to raise_error
    expect(@img.offset).to eq(10)
    expect { @img.offset = 'x' }.to raise_error(TypeError)
  end

  def test_orientation
    expect { @img.orientation }.not_to raise_error
    assert_instance_of(Magick::OrientationType, @img.orientation)
    expect(@img.orientation).to eq(Magick::UndefinedOrientation)
    expect { @img.orientation = Magick::TopLeftOrientation }.not_to raise_error
    expect(@img.orientation).to eq(Magick::TopLeftOrientation)

    Magick::OrientationType.values do |orientation|
      expect { @img.orientation = orientation }.not_to raise_error
    end
    expect { @img.orientation = 2 }.to raise_error(TypeError)
  end

  def test_page
    expect { @img.page }.not_to raise_error
    page = @img.page
    expect(page.width).to eq(0)
    expect(page.height).to eq(0)
    expect(page.x).to eq(0)
    expect(page.y).to eq(0)
    page = Magick::Rectangle.new(1, 2, 3, 4)
    expect { @img.page = page }.not_to raise_error
    expect(page.width).to eq(1)
    expect(page.height).to eq(2)
    expect(page.x).to eq(3)
    expect(page.y).to eq(4)
    expect { @img.page = 2 }.to raise_error(TypeError)
  end

  def test_pixel_interpolation_method
    expect { @img.pixel_interpolation_method }.not_to raise_error
    assert_instance_of(Magick::PixelInterpolateMethod, @img.pixel_interpolation_method)
    expect(@img.pixel_interpolation_method).to eq(Magick::UndefinedInterpolatePixel)
    expect { @img.pixel_interpolation_method = Magick::AverageInterpolatePixel }.not_to raise_error
    expect(@img.pixel_interpolation_method).to eq(Magick::AverageInterpolatePixel)

    Magick::PixelInterpolateMethod.values do |interpolate_pixel_method|
      expect { @img.pixel_interpolation_method = interpolate_pixel_method }.not_to raise_error
    end
    expect { @img.pixel_interpolation_method = 2 }.to raise_error(TypeError)
  end

  def test_quality
    expect { @hat.quality }.not_to raise_error
    expect(@hat.quality).to eq(75)
    expect { @img.quality = 80 }.to raise_error(NoMethodError)
  end

  def test_quantum_depth
    expect { @img.quantum_depth }.not_to raise_error
    expect(@img.quantum_depth).to eq(Magick::MAGICKCORE_QUANTUM_DEPTH)
    expect { @img.quantum_depth = 8 }.to raise_error(NoMethodError)
  end

  def test_rendering_intent
    expect { @img.rendering_intent }.not_to raise_error
    assert_instance_of(Magick::RenderingIntent, @img.rendering_intent)
    expect(@img.rendering_intent).to eq(Magick::PerceptualIntent)

    Magick::RenderingIntent.values do |rendering_intent|
      expect { @img.rendering_intent = rendering_intent }.not_to raise_error
    end
    expect { @img.rendering_intent = 2 }.to raise_error(TypeError)
  end

  def test_rows
    expect { @img.rows }.not_to raise_error
    expect(@img.rows).to eq(100)
    expect { @img.rows = 2 }.to raise_error(NoMethodError)
  end

  def test_scene
    ilist = Magick::ImageList.new
    ilist << @img
    img = @img.copy
    ilist << img
    ilist.write('temp.gif')
    FileUtils.rm('temp.gif')

    expect { img.scene }.not_to raise_error
    expect(@img.scene).to eq(0)
    expect(img.scene).to eq(1)
    expect { img.scene = 2 }.to raise_error(NoMethodError)
  end

  def test_start_loop
    expect { @img.start_loop }.not_to raise_error
    assert(!@img.start_loop)
    expect { @img.start_loop = true }.not_to raise_error
    assert(@img.start_loop)
  end

  def test_ticks_per_second
    expect { @img.ticks_per_second }.not_to raise_error
    expect(@img.ticks_per_second).to eq(100)
    expect { @img.ticks_per_second = 1000 }.not_to raise_error
    expect(@img.ticks_per_second).to eq(1000)
    expect { @img.ticks_per_second = 'x' }.to raise_error(TypeError)
  end

  def test_total_colors
    expect { @hat.total_colors }.not_to raise_error
    assert_kind_of(Integer, @hat.total_colors)
    expect { @img.total_colors = 2 }.to raise_error(NoMethodError)
  end

  def test_units
    expect { @img.units }.not_to raise_error
    assert_instance_of(Magick::ResolutionType, @img.units)
    expect(@img.units).to eq(Magick::UndefinedResolution)
    expect { @img.units = Magick::PixelsPerInchResolution }.not_to raise_error
    expect(@img.units).to eq(Magick::PixelsPerInchResolution)

    Magick::ResolutionType.values do |resolution|
      expect { @img.units = resolution }.not_to raise_error
    end
    expect { @img.units = 2 }.to raise_error(TypeError)
  end

  def test_virtual_pixel_method
    expect { @img.virtual_pixel_method }.not_to raise_error
    expect(@img.virtual_pixel_method).to eq(Magick::UndefinedVirtualPixelMethod)
    expect { @img.virtual_pixel_method = Magick::EdgeVirtualPixelMethod }.not_to raise_error
    expect(@img.virtual_pixel_method).to eq(Magick::EdgeVirtualPixelMethod)

    Magick::VirtualPixelMethod.values do |virtual_pixel_method|
      expect { @img.virtual_pixel_method = virtual_pixel_method }.not_to raise_error
    end
    expect { @img.virtual_pixel_method = 2 }.to raise_error(TypeError)
  end

  def test_x_resolution
    expect { @img.x_resolution }.not_to raise_error
    expect { @img.x_resolution = 90 }.not_to raise_error
    expect(@img.x_resolution).to eq(90.0)
    expect { @img.x_resolution = 'x' }.to raise_error(TypeError)
  end

  def test_y_resolution
    expect { @img.y_resolution }.not_to raise_error
    expect { @img.y_resolution = 90 }.not_to raise_error
    expect(@img.y_resolution).to eq(90.0)
    expect { @img.y_resolution = 'x' }.to raise_error(TypeError)
  end

  def test_frozen
    @img.freeze
    expect { @img.background_color = 'xxx' }.to raise_error(FreezeError)
    expect { @img.border_color = 'xxx' }.to raise_error(FreezeError)
    rp = Magick::Point.new(1, 1)
    gp = Magick::Point.new(1, 1)
    bp = Magick::Point.new(1, 1)
    wp = Magick::Point.new(1, 1)
    expect { @img.chromaticity = Magick::Chromaticity.new(rp, gp, bp, wp) }.to raise_error(FreezeError)
    expect { @img.class_type = Magick::DirectClass }.to raise_error(FreezeError)
    expect { @img.color_profile = 'xxx' }.to raise_error(FreezeError)
    expect { @img.colorspace = Magick::RGBColorspace }.to raise_error(FreezeError)
    expect { @img.compose = Magick::OverCompositeOp }.to raise_error(FreezeError)
    expect { @img.compression = Magick::RLECompression }.to raise_error(FreezeError)
    expect { @img.delay = 2 }.to raise_error(FreezeError)
    expect { @img.density = '72.0x72.0' }.to raise_error(FreezeError)
    expect { @img.dispose = Magick::NoneDispose }.to raise_error(FreezeError)
    expect { @img.endian = Magick::MSBEndian }.to raise_error(FreezeError)
    expect { @img.extract_info = Magick::Rectangle.new(1, 2, 3, 4) }.to raise_error(FreezeError)
    expect { @img.filter = Magick::PointFilter }.to raise_error(FreezeError)
    expect { @img.format = 'GIF' }.to raise_error(FreezeError)
    expect { @img.fuzz = 50.0 }.to raise_error(FreezeError)
    expect { @img.gamma = 2.0 }.to raise_error(FreezeError)
    expect { @img.geometry = '100x100' }.to raise_error(FreezeError)
    expect { @img.interlace = Magick::NoInterlace }.to raise_error(FreezeError)
    expect { @img.iptc_profile = 'xxx' }.to raise_error(FreezeError)
    expect { @img.monitor = proc { |name, _q, _s| puts name } }.to raise_error(FreezeError)
    expect { @img.offset = 100 }.to raise_error(FreezeError)
    expect { @img.page = Magick::Rectangle.new(1, 2, 3, 4) }.to raise_error(FreezeError)
    expect { @img.rendering_intent = Magick::SaturationIntent }.to raise_error(FreezeError)
    expect { @img.start_loop = true }.to raise_error(FreezeError)
    expect { @img.ticks_per_second = 1000 }.to raise_error(FreezeError)
    expect { @img.units = Magick::PixelsPerInchResolution }.to raise_error(FreezeError)
    expect { @img.x_resolution = 72.0 }.to raise_error(FreezeError)
    expect { @img.y_resolution = 72.0 }.to raise_error(FreezeError)
  end
end # class Image_Attributes_UT

if $PROGRAM_NAME == __FILE__
  FLOWER_HAT = '../doc/ex/images/Flower_Hat.jpg'
  Test::Unit::UI::Console::TestRunner.run(ImageAttributesUT)
end
