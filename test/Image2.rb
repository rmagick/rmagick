require 'rmagick'
require 'minitest/autorun'

# TODO: improve exif tests - need a benchmark image with EXIF data

class Image2_UT < Minitest::Test
  def setup
    @img = Magick::Image.new(20, 20)
  end

  def test_composite
    img1 = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    img2 = Magick::Image.read(IMAGES_DIR + '/Button_1.gif').first
    img1.define('compose:args', '1x1')
    img2.define('compose:args', '1x1')
    Magick::CompositeOperator.values do |op|
      Magick::GravityType.values do |gravity|
        expect do
          res = img1.composite(img2, gravity, 5, 5, op)
          expect(res).not_to be(img1)
        end.not_to raise_error
      end
    end

    expect do
      res = img1.composite(img2, 5, 5, Magick::OverCompositeOp)
      expect(res).not_to be(img1)
    end.not_to raise_error

    expect { img1.composite(img2, 'x', 5, Magick::OverCompositeOp) }.to raise_error(TypeError)
    expect { img1.composite(img2, 5, 'y', Magick::OverCompositeOp) }.to raise_error(TypeError)
    expect { img1.composite(img2, Magick::NorthWestGravity, 'x', 5, Magick::OverCompositeOp) }.to raise_error(TypeError)
    expect { img1.composite(img2, Magick::NorthWestGravity, 5, 'y', Magick::OverCompositeOp) }.to raise_error(TypeError)

    img1.freeze
    expect { img1.composite(img2, Magick::NorthWestGravity, Magick::OverCompositeOp) }.not_to raise_error
  end

  def test_composite!
    img1 = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    img2 = Magick::Image.read(IMAGES_DIR + '/Button_1.gif').first
    img1.define('compose:args', '1x1')
    img2.define('compose:args', '1x1')
    Magick::CompositeOperator.values do |op|
      Magick::GravityType.values do |gravity|
        expect do
          res = img1.composite!(img2, gravity, op)
          expect(res).to be(img1)
        end.not_to raise_error
      end
    end
    img1.freeze
    expect { img1.composite!(img2, Magick::NorthWestGravity, Magick::OverCompositeOp) }.to raise_error(FreezeError)
  end

  def test_composite_affine
    affine = Magick::AffineMatrix.new(1, 0, 1, 0, 0, 0)
    img1 = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    img2 = Magick::Image.read(IMAGES_DIR + '/Button_1.gif').first
    img1.define('compose:args', '1x1')
    img2.define('compose:args', '1x1')
    expect do
      res = img1.composite_affine(img2, affine)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
  end

  def test_composite_channel
    img1 = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    img2 = Magick::Image.read(IMAGES_DIR + '/Button_1.gif').first
    img1.define('compose:args', '1x1')
    img2.define('compose:args', '1x1')
    Magick::CompositeOperator.values do |op|
      Magick::GravityType.values do |gravity|
        expect do
          res = img1.composite_channel(img2, gravity, 5, 5, op, Magick::BlueChannel)
          expect(res).not_to be(img1)
        end.not_to raise_error
      end
    end

    expect { img1.composite_channel(img2, Magick::NorthWestGravity) }.to raise_error(ArgumentError)
    expect { img1.composite_channel(img2, Magick::NorthWestGravity, 5, 5, Magick::OverCompositeOp, 'x') }.to raise_error(TypeError)
  end

  def test_composite_mathematics
    bg = Magick::Image.new(50, 50)
    fg = Magick::Image.new(50, 50) { self.background_color = 'black' }
    res = nil
    expect { res = bg.composite_mathematics(fg, 1, 0, 0, 0, Magick::CenterGravity) }.not_to raise_error
    expect(res).to be_instance_of(Magick::Image)
    expect(res).not_to be(bg)
    expect(res).not_to be(fg)
    expect { res = bg.composite_mathematics(fg, 1, 0, 0, 0, 0.0, 0.0) }.not_to raise_error
    expect { res = bg.composite_mathematics(fg, 1, 0, 0, 0, Magick::CenterGravity, 0.0, 0.0) }.not_to raise_error

    # too few arguments
    expect { bg.composite_mathematics(fg, 1, 0, 0, 0) }.to raise_error(ArgumentError)
    # too many arguments
    expect { bg.composite_mathematics(fg, 1, 0, 0, 0, Magick::CenterGravity, 0.0, 0.0, 'x') }.to raise_error(ArgumentError)
  end

  def test_composite_tiled
    bg = Magick::Image.new(200, 200)
    fg = Magick::Image.new(50, 100) { self.background_color = 'black' }
    res = nil
    expect do
      res = bg.composite_tiled(fg)
    end.not_to raise_error
    expect(res).to be_instance_of(Magick::Image)
    expect(res).not_to be(bg)
    expect(res).not_to be(fg)
    expect { bg.composite_tiled!(fg) }.not_to raise_error
    expect { bg.composite_tiled(fg, Magick::AtopCompositeOp) }.not_to raise_error
    expect { bg.composite_tiled(fg, Magick::OverCompositeOp) }.not_to raise_error
    expect { bg.composite_tiled(fg, Magick::RedChannel) }.not_to raise_error
    expect { bg.composite_tiled(fg, Magick::RedChannel, Magick::GreenChannel) }.not_to raise_error

    expect { bg.composite_tiled }.to raise_error(ArgumentError)
    expect { bg.composite_tiled(fg, 'x') }.to raise_error(TypeError)
    expect { bg.composite_tiled(fg, Magick::AtopCompositeOp, Magick::RedChannel, 'x') }.to raise_error(TypeError)

    fg.destroy!
    expect { bg.composite_tiled(fg) }.to raise_error(Magick::DestroyedImageError)
  end

  def test_compress_colormap!
    # DirectClass images are converted to PseudoClass in older versions of ImageMagick.
    expect(@img.class_type).to eq(Magick::DirectClass)
    expect { @img.compress_colormap! }.not_to raise_error
    # expect(@img.class_type).to eq(Magick::PseudoClass)
    @img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    expect(@img.class_type).to eq(Magick::PseudoClass)
    expect { @img.compress_colormap! }.not_to raise_error
  end

  def test_contrast
    expect do
      res = @img.contrast
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.contrast(true) }.not_to raise_error
    expect { @img.contrast(true, 2) }.to raise_error(ArgumentError)
  end

  def test_contrast_stretch_channel
    expect do
      res = @img.contrast_stretch_channel(25)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.contrast_stretch_channel(25, 50) }.not_to raise_error
    expect { @img.contrast_stretch_channel('10%') }.not_to raise_error
    expect { @img.contrast_stretch_channel('10%', '50%') }.not_to raise_error
    expect { @img.contrast_stretch_channel(25, 50, Magick::RedChannel) }.not_to raise_error
    expect { @img.contrast_stretch_channel(25, 50, Magick::RedChannel, Magick::GreenChannel) }.not_to raise_error
    expect { @img.contrast_stretch_channel(25, 50, 'x') }.to raise_error(TypeError)
    expect { @img.contrast_stretch_channel }.to raise_error(ArgumentError)
    expect { @img.contrast_stretch_channel('x') }.to raise_error(ArgumentError)
    expect { @img.contrast_stretch_channel(25, 'x') }.to raise_error(ArgumentError)
  end

  def test_morphology
    kernel = Magick::KernelInfo.new('Octagon')
    Magick::MorphologyMethod.values do |method|
      expect do
        res = @img.morphology(method, 2, kernel)
        expect(res).to be_instance_of(Magick::Image)
        expect(res).not_to be(@img)
      end.not_to raise_error
    end
  end

  def test_morphology_channel
    expect { @img.morphology_channel }.to raise_error(ArgumentError)
    expect { @img.morphology_channel(Magick::RedChannel) }.to raise_error(ArgumentError)
    expect { @img.morphology_channel(Magick::RedChannel, Magick::EdgeOutMorphology) }.to raise_error(ArgumentError)
    expect { @img.morphology_channel(Magick::RedChannel, Magick::EdgeOutMorphology, 2) }.to raise_error(ArgumentError)
    expect { @img.morphology_channel(Magick::RedChannel, Magick::EdgeOutMorphology, 2, :not_kernel_info) }.to raise_error(ArgumentError)

    kernel = Magick::KernelInfo.new('Octagon')
    expect do
      res = @img.morphology_channel(Magick::RedChannel, Magick::EdgeOutMorphology, 2, kernel)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
  end

  def test_convolve
    kernel = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    order = 3
    expect do
      res = @img.convolve(order, kernel)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.convolve }.to raise_error(ArgumentError)
    expect { @img.convolve(0) }.to raise_error(ArgumentError)
    expect { @img.convolve(-1) }.to raise_error(ArgumentError)
    expect { @img.convolve(order) }.to raise_error(ArgumentError)
    expect { @img.convolve(5, kernel) }.to raise_error(IndexError)
    expect { @img.convolve(order, 'x') }.to raise_error(IndexError)
    expect { @img.convolve(3, [1.0, 1.0, 1.0, 1.0, 'x', 1.0, 1.0, 1.0, 1.0]) }.to raise_error(TypeError)
    expect { @img.convolve(-1, [1.0, 1.0, 1.0, 1.0]) }.to raise_error(ArgumentError)
  end

  def test_convolve_channel
    expect { @img.convolve_channel }.to raise_error(ArgumentError)
    expect { @img.convolve_channel(0) }.to raise_error(ArgumentError)
    expect { @img.convolve_channel(-1) }.to raise_error(ArgumentError)
    expect { @img.convolve_channel(3) }.to raise_error(ArgumentError)
    kernel = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    order = 3
    expect do
      res = @img.convolve_channel(order, kernel, Magick::RedChannel)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error

    expect { @img.convolve_channel(order, kernel, Magick::RedChannel, Magick:: BlueChannel) }.not_to raise_error
    expect { @img.convolve_channel(order, kernel, Magick::RedChannel, 2) }.to raise_error(TypeError)
  end

  def test_copy
    expect do
      ditto = @img.copy
      expect(ditto).to eq(@img)
    end.not_to raise_error
    ditto = @img.copy
    expect(ditto.tainted?).to eq(@img.tainted?)
    @img.taint
    ditto = @img.copy
    expect(ditto.tainted?).to eq(@img.tainted?)
  end

  def test_crop
    expect { @img.crop }.to raise_error(ArgumentError)
    expect { @img.crop(0, 0) }.to raise_error(ArgumentError)
    expect do
      res = @img.crop(0, 0, @img.columns / 2, @img.rows / 2)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error

    # 3-argument form
    Magick::GravityType.values do |grav|
      expect { @img.crop(grav, @img.columns / 2, @img.rows / 2) }.not_to raise_error
    end
    expect { @img.crop(2, @img.columns / 2, @img.rows / 2) }.to raise_error(TypeError)
    expect { @img.crop(Magick::NorthWestGravity, @img.columns / 2, @img.rows / 2, 2) }.to raise_error(TypeError)

    # 4-argument form
    expect { @img.crop(0, 0, @img.columns / 2, 'x') }.to raise_error(TypeError)
    expect { @img.crop(0, 0, 'x', @img.rows / 2) }.to raise_error(TypeError)
    expect { @img.crop(0, 'x', @img.columns / 2, @img.rows / 2) }.to raise_error(TypeError)
    expect { @img.crop('x', 0, @img.columns / 2, @img.rows / 2) }.to raise_error(TypeError)
    expect { @img.crop(0, 0, @img.columns / 2, @img.rows / 2, 2) }.to raise_error(TypeError)

    # 5-argument form
    Magick::GravityType.values do |grav|
      expect { @img.crop(grav, 0, 0, @img.columns / 2, @img.rows / 2) }.not_to raise_error
    end

    expect { @img.crop(Magick::NorthWestGravity, 0, 0, @img.columns / 2, @img.rows / 2, 2) }.to raise_error(ArgumentError)
  end

  def test_crop!
    expect do
      res = @img.crop!(0, 0, @img.columns / 2, @img.rows / 2)
      expect(res).to be(@img)
    end.not_to raise_error
  end

  def test_cycle_colormap
    expect do
      res = @img.cycle_colormap(5)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
      expect(res.class_type).to eq(Magick::PseudoClass)
    end.not_to raise_error
  end

  def test_decipher # tests encipher, too.
    res = res2 = nil
    expect do
      res = @img.encipher 'passphrase'
      res2 = res.decipher 'passphrase'
    end.not_to raise_error
    expect(res).to be_instance_of(Magick::Image)
    expect(res).not_to be(@img)
    expect(res.columns).to eq(@img.columns)
    expect(res.rows).to eq(@img.rows)
    expect(res2).to be_instance_of(Magick::Image)
    expect(res2).not_to be(@img)
    expect(res2.columns).to eq(@img.columns)
    expect(res2.rows).to eq(@img.rows)
    expect(res2).to eq(@img)
  end

  def test_define
    expect { @img.define('deskew:auto-crop', 40) }.not_to raise_error
    expect { @img.undefine('deskew:auto-crop') }.not_to raise_error
    expect { @img.define('deskew:auto-crop', nil) }.not_to raise_error
  end

  def test_deskew
    expect do
      res = @img.deskew
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error

    expect { @img.deskew(0.10) }.not_to raise_error
    expect { @img.deskew('95%') }.not_to raise_error
    expect { @img.deskew('x') }.to raise_error(ArgumentError)
    expect { @img.deskew(0.40, 'x') }.to raise_error(TypeError)
    expect { @img.deskew(0.40, 20, [1]) }.to raise_error(ArgumentError)
  end

  def test_despeckle
    expect do
      res = @img.despeckle
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
  end

  # ensure methods detect destroyed images
  def test_destroy
    methods = Magick::Image.instance_methods(false).sort
    methods -= %i[__display__ destroy! destroyed? inspect cur_image marshal_load]

    expect(@img.destroyed?).to eq(false)
    @img.destroy!
    expect(@img.destroyed?).to eq(true)
    expect { @img.check_destroyed }.to raise_error(Magick::DestroyedImageError)

    methods.each do |method|
      arity = @img.method(method).arity
      method = method.to_s

      if method == '[]='
        expect { @img['foo'] = 1 }.to raise_error(Magick::DestroyedImageError)
      elsif method == 'difference'
        other = Magick::Image.new(20, 20)
        expect { @img.difference(other) }.to raise_error(Magick::DestroyedImageError)
      elsif method == 'channel_entropy' && IM_VERSION < Gem::Version.new('6.9')
        expect { @img.channel_entropy }.to raise_error(NotImplementedError)
      elsif method == 'get_iptc_dataset'
        expect { @img.get_iptc_dataset('x') }.to raise_error(Magick::DestroyedImageError)
      elsif method == 'profile!'
        expect { @img.profile!('x', 'y') }.to raise_error(Magick::DestroyedImageError)
      elsif /=\Z/.match(method)
        expect { @img.send(method, 1) }.to raise_error(Magick::DestroyedImageError)
      elsif arity.zero?
        expect { @img.send(method) }.to raise_error(Magick::DestroyedImageError)
      elsif arity < 0
        args = (1..-arity).to_a
        expect { @img.send(method, *args) }.to raise_error(Magick::DestroyedImageError)
      elsif arity > 0
        args = (1..arity).to_a
        expect { @img.send(method, *args) }.to raise_error(Magick::DestroyedImageError)
      else
        # Don't know how to test!
        flunk("don't know how to test method #{method}")
      end
    end
  end

  # ensure destroy! works
  def test_destroy2
    images = {}
    GC.disable

    Magick.trace_proc = proc do |which, id, addr, method|
      m = id.split(/ /)
      name = File.basename m[0]

      assert(%i[c d].include?(which), "unexpected value for which: #{which}")
      expect(method).to eq(:destroy!) if which == :d

      if which == :c
        assert(!images.key?(addr), 'duplicate image addresses')
        images[addr] = name
      else
        assert(images.key?(addr), 'destroying image that was not created')
        expect(images[addr]).to eq(name)
      end
    end

    unmapped = Magick::ImageList.new(IMAGES_DIR + '/Hot_Air_Balloons.jpg', IMAGES_DIR + '/Violin.jpg', IMAGES_DIR + '/Polynesia.jpg')
    map = Magick::ImageList.new 'netscape:'
    mapped = unmapped.remap map
    unmapped.each(&:destroy!)
    map.destroy!
    mapped.each(&:destroy!)
  ensure
    GC.enable
    Magick.trace_proc = nil
  end

  def test_difference
    img1 = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    img2 = Magick::Image.read(IMAGES_DIR + '/Button_1.gif').first
    expect do
      res = img1.difference(img2)
      expect(res).to be_instance_of(Array)
      expect(res.length).to eq(3)
      expect(res[0]).to be_instance_of(Float)
      expect(res[1]).to be_instance_of(Float)
      expect(res[2]).to be_instance_of(Float)
    end.not_to raise_error

    expect { img1.difference(2) }.to raise_error(NoMethodError)
    img2.destroy!
    expect { img1.difference(img2) }.to raise_error(Magick::DestroyedImageError)
  end

  def test_displace
    @img2 = Magick::Image.new(20, 20) { self.background_color = 'black' }
    expect { @img.displace(@img2, 25) }.not_to raise_error
    res = @img.displace(@img2, 25)
    expect(res).to be_instance_of(Magick::Image)
    expect(res).not_to be(@img)
    expect { @img.displace(@img2, 25, 25) }.not_to raise_error
    expect { @img.displace(@img2, 25, 25, 10) }.not_to raise_error
    expect { @img.displace(@img2, 25, 25, 10, 10) }.not_to raise_error
    expect { @img.displace(@img2, 25, 25, Magick::CenterGravity) }.not_to raise_error
    expect { @img.displace(@img2, 25, 25, Magick::CenterGravity, 10) }.not_to raise_error
    expect { @img.displace(@img2, 25, 25, Magick::CenterGravity, 10, 10) }.not_to raise_error
    expect { @img.displace }.to raise_error(ArgumentError)
    expect { @img.displace(@img2, 'x') }.to raise_error(TypeError)
    expect { @img.displace(@img2, 25, []) }.to raise_error(TypeError)
    expect { @img.displace(@img2, 25, 25, 'x') }.to raise_error(TypeError)
    expect { @img.displace(@img2, 25, 25, Magick::CenterGravity, 'x') }.to raise_error(TypeError)
    expect { @img.displace(@img2, 25, 25, Magick::CenterGravity, 10, []) }.to raise_error(TypeError)

    @img2.destroy!
    expect { @img.displace(@img2, 25, 25) }.to raise_error(Magick::DestroyedImageError)
  end

  def test_dissolve
    src = Magick::Image.new(@img.columns, @img.rows)
    src_list = Magick::ImageList.new
    src_list << src.copy
    expect { @img.dissolve(src, 0.50) }.not_to raise_error
    expect { @img.dissolve(src_list, 0.50) }.not_to raise_error
    expect { @img.dissolve(src, '50%') }.not_to raise_error
    expect { @img.dissolve(src, 0.50, 0.10) }.not_to raise_error
    expect { @img.dissolve(src, 0.50, 0.10, 10) }.not_to raise_error
    expect { @img.dissolve(src, 0.50, 0.10, Magick::NorthEastGravity) }.not_to raise_error
    expect { @img.dissolve(src, 0.50, 0.10, Magick::NorthEastGravity, 10) }.not_to raise_error
    expect { @img.dissolve(src, 0.50, 0.10, Magick::NorthEastGravity, 10, 10) }.not_to raise_error

    expect { @img.dissolve }.to raise_error(ArgumentError)
    expect { @img.dissolve(src, 'x') }.to raise_error(ArgumentError)
    expect { @img.dissolve(src, 0.50, 'x') }.to raise_error(ArgumentError)
    expect { @img.dissolve(src, 0.50, Magick::NorthEastGravity, 'x') }.to raise_error(TypeError)
    expect { @img.dissolve(src, 0.50, Magick::NorthEastGravity, 10, 'x') }.to raise_error(TypeError)

    src.destroy!
    expect { @img.dissolve(src, 0.50) }.to raise_error(Magick::DestroyedImageError)
  end

  def test_distort
    @img = Magick::Image.new(200, 200)
    expect { @img.distort(Magick::AffineDistortion, [2, 60, 2, 60, 32, 60, 32, 60, 2, 30, 17, 35]) }.not_to raise_error
    expect { @img.distort(Magick::AffineProjectionDistortion, [1, 0, 0, 1, 0, 0]) }.not_to raise_error
    expect { @img.distort(Magick::BilinearDistortion, [7, 40, 4, 30, 4, 124, 4, 123, 85, 122, 100, 123, 85, 2, 100, 30]) }.not_to raise_error
    expect { @img.distort(Magick::PerspectiveDistortion, [7, 40, 4, 30,   4, 124, 4, 123, 85, 122, 100, 123, 85, 2, 100, 30]) }.not_to raise_error
    expect { @img.distort(Magick::ScaleRotateTranslateDistortion, [28, 24, 0.4, 0.8 - 110, 37.5, 60]) }.not_to raise_error
    expect { @img.distort(Magick::ScaleRotateTranslateDistortion, [28, 24, 0.4, 0.8 - 110, 37.5, 60], true) }.not_to raise_error
    expect { @img.distort }.to raise_error(ArgumentError)
    expect { @img.distort(Magick::AffineDistortion) }.to raise_error(ArgumentError)
    expect { @img.distort(1, [1]) }.to raise_error(TypeError)
    expect { @img.distort(Magick::AffineDistortion, [2, 60, 2, 60, 32, 60, 32, 60, 2, 30, 17, 'x']) }.to raise_error(TypeError)
  end

  def test_distortion_channel
    expect do
      metric = @img.distortion_channel(@img, Magick::MeanAbsoluteErrorMetric)
      expect(metric).to be_instance_of(Float)
      expect(metric).to eq(0.0)
    end.not_to raise_error
    expect { @img.distortion_channel(@img, Magick::MeanSquaredErrorMetric) }.not_to raise_error
    expect { @img.distortion_channel(@img, Magick::PeakAbsoluteErrorMetric) }.not_to raise_error
    expect { @img.distortion_channel(@img, Magick::PeakSignalToNoiseRatioErrorMetric) }.not_to raise_error
    expect { @img.distortion_channel(@img, Magick::RootMeanSquaredErrorMetric) }.not_to raise_error
    expect { @img.distortion_channel(@img, Magick::MeanSquaredErrorMetric, Magick::RedChannel, Magick:: BlueChannel) }.not_to raise_error
    expect { @img.distortion_channel(@img, Magick::NormalizedCrossCorrelationErrorMetric) }.not_to raise_error
    expect { @img.distortion_channel(@img, Magick::FuzzErrorMetric) }.not_to raise_error
    expect { @img.distortion_channel(@img, 2) }.to raise_error(TypeError)
    expect { @img.distortion_channel(@img, Magick::RootMeanSquaredErrorMetric, 2) }.to raise_error(TypeError)
    expect { @img.distortion_channel }.to raise_error(ArgumentError)
    expect { @img.distortion_channel(@img) }.to raise_error(ArgumentError)

    img = Magick::Image.new(20, 20)
    img.destroy!
    expect { @img.distortion_channel(img, Magick::MeanSquaredErrorMetric) }.to raise_error(Magick::DestroyedImageError)
  end

  def test__dump
    img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    expect(img._dump(10)).to be_instance_of(String)
  end

  def test__load
    img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    res = img._dump(10)

    expect(Magick::Image._load(res)).to be_instance_of(Magick::Image)
  end

  def test_dup
    expect do
      ditto = @img.dup
      expect(ditto).to eq(@img)
    end.not_to raise_error
    ditto = @img.dup
    expect(ditto.tainted?).to eq(@img.tainted?)
    @img.taint
    ditto = @img.dup
    expect(ditto.tainted?).to eq(@img.tainted?)
  end

  def test_each_profile
    assert_nil(@img.each_profile {})

    @img.iptc_profile = 'test profile'
    expect do
      @img.each_profile do |name, value|
        expect(name).to eq('iptc')
        expect(value).to eq('test profile')
      end
    end.not_to raise_error
  end

  def test_edge
    expect do
      res = @img.edge
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.edge(2.0) }.not_to raise_error
    expect { @img.edge(2.0, 2) }.to raise_error(ArgumentError)
    expect { @img.edge('x') }.to raise_error(TypeError)
  end

  def test_emboss
    expect do
      res = @img.emboss
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.emboss(1.0) }.not_to raise_error
    expect { @img.emboss(1.0, 0.5) }.not_to raise_error
    expect { @img.emboss(1.0, 0.5, 2) }.to raise_error(ArgumentError)
    expect { @img.emboss(1.0, 'x') }.to raise_error(TypeError)
    expect { @img.emboss('x', 1.0) }.to raise_error(TypeError)
  end

  def test_enhance
    expect do
      res = @img.enhance
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
  end

  def test_equalize
    expect do
      res = @img.equalize
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
  end

  def test_equalize_channel
    expect do
      res = @img.equalize_channel
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.equalize_channel }.not_to raise_error
    expect { @img.equalize_channel(Magick::RedChannel) }.not_to raise_error
    expect { @img.equalize_channel(Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.equalize_channel(Magick::RedChannel, 2) }.to raise_error(TypeError)
  end

  def test_erase!
    expect do
      res = @img.erase!
      expect(res).to be(@img)
    end.not_to raise_error
  end

  def test_excerpt
    res = nil
    img = Magick::Image.new(200, 200)
    expect { res = @img.excerpt(20, 20, 50, 100) }.not_to raise_error
    expect(res).not_to be(img)
    expect(res.columns).to eq(50)
    expect(res.rows).to eq(100)

    expect { img.excerpt!(20, 20, 50, 100) }.not_to raise_error
    expect(img.columns).to eq(50)
    expect(img.rows).to eq(100)
  end

  def test_export_pixels
    expect do
      res = @img.export_pixels
      expect(res).to be_instance_of(Array)
      expect(res.length).to eq(@img.columns * @img.rows * 'RGB'.length)
      res.each do |p|
        assert_kind_of(Integer, p)
      end
    end.not_to raise_error
    expect { @img.export_pixels(0) }.not_to raise_error
    expect { @img.export_pixels(0, 0) }.not_to raise_error
    expect { @img.export_pixels(0, 0, 10) }.not_to raise_error
    expect { @img.export_pixels(0, 0, 10, 10) }.not_to raise_error
    expect do
      res = @img.export_pixels(0, 0, 10, 10, 'RGBA')
      expect(res.length).to eq(10 * 10 * 'RGBA'.length)
    end.not_to raise_error
    expect do
      res = @img.export_pixels(0, 0, 10, 10, 'I')
      expect(res.length).to eq(10 * 10 * 'I'.length)
    end.not_to raise_error

    # too many arguments
    expect { @img.export_pixels(0, 0, 10, 10, 'I', 2) }.to raise_error(ArgumentError)
  end

  def test_export_pixels_to_str
    expect do
      res = @img.export_pixels_to_str
      expect(res).to be_instance_of(String)
      expect(res.length).to eq(@img.columns * @img.rows * 'RGB'.length)
    end.not_to raise_error
    expect { @img.export_pixels_to_str(0) }.not_to raise_error
    expect { @img.export_pixels_to_str(0, 0) }.not_to raise_error
    expect { @img.export_pixels_to_str(0, 0, 10) }.not_to raise_error
    expect { @img.export_pixels_to_str(0, 0, 10, 10) }.not_to raise_error
    expect do
      res = @img.export_pixels_to_str(0, 0, 10, 10, 'RGBA')
      expect(res.length).to eq(10 * 10 * 'RGBA'.length)
    end.not_to raise_error
    expect do
      res = @img.export_pixels_to_str(0, 0, 10, 10, 'I')
      expect(res.length).to eq(10 * 10 * 'I'.length)
    end.not_to raise_error

    expect do
      res = @img.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::CharPixel)
      expect(res.length).to eq(10 * 10 * 1)
    end.not_to raise_error
    expect do
      res = @img.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::ShortPixel)
      expect(res.length).to eq(10 * 10 * 2)
    end.not_to raise_error
    expect do
      res = @img.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::LongPixel)
      expect(res.length).to eq(10 * 10 * [1].pack('L!').length)
    end.not_to raise_error
    expect do
      res = @img.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::FloatPixel)
      expect(res.length).to eq(10 * 10 * 4)
    end.not_to raise_error
    expect do
      res = @img.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::DoublePixel)
      expect(res.length).to eq(10 * 10 * 8)
    end.not_to raise_error
    expect { @img.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::QuantumPixel) }.not_to raise_error

    # too many arguments
    expect { @img.export_pixels_to_str(0, 0, 10, 10, 'I', Magick::QuantumPixel, 1) }.to raise_error(ArgumentError)
    # last arg s/b StorageType
    expect { @img.export_pixels_to_str(0, 0, 10, 10, 'I', 2) }.to raise_error(TypeError)
  end

  def test_extent
    expect { @img.extent(40, 40) }.not_to raise_error
    res = @img.extent(40, 40)
    expect(res).to be_instance_of(Magick::Image)
    expect(res).not_to be(@img)
    expect(res.columns).to eq(40)
    expect(res.rows).to eq(40)
    expect { @img.extent(40, 40, 5) }.not_to raise_error
    expect { @img.extent(40, 40, 5, 5) }.not_to raise_error
    expect { @img.extent(-40) }.to raise_error(ArgumentError)
    expect { @img.extent(-40, 40) }.to raise_error(ArgumentError)
    expect { @img.extent(40, -40) }.to raise_error(ArgumentError)
    expect { @img.extent(40, 40, 5, 5, 0) }.to raise_error(ArgumentError)
    expect { @img.extent(0, 0, 5, 5) }.to raise_error(ArgumentError)
    expect { @img.extent('x', 40) }.to raise_error(TypeError)
    expect { @img.extent(40, 'x') }.to raise_error(TypeError)
    expect { @img.extent(40, 40, 'x') }.to raise_error(TypeError)
    expect { @img.extent(40, 40, 5, 'x') }.to raise_error(TypeError)
  end

  def test_find_similar_region
    girl = Magick::Image.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    region = girl.crop(10, 10, 50, 50)
    expect do
      x, y = girl.find_similar_region(region)
      assert_not_nil(x)
      assert_not_nil(y)
      expect(x).to eq(10)
      expect(y).to eq(10)
    end.not_to raise_error
    expect do
      x, y = girl.find_similar_region(region, 0)
      expect(x).to eq(10)
      expect(y).to eq(10)
    end.not_to raise_error
    expect do
      x, y = girl.find_similar_region(region, 0, 0)
      expect(x).to eq(10)
      expect(y).to eq(10)
    end.not_to raise_error

    list = Magick::ImageList.new
    list << region
    expect do
      x, y = girl.find_similar_region(list, 0, 0)
      expect(x).to eq(10)
      expect(y).to eq(10)
    end.not_to raise_error

    x = girl.find_similar_region(@img)
    assert_nil(x)

    expect { girl.find_similar_region(region, 10, 10, 10) }.to raise_error(ArgumentError)
    expect { girl.find_similar_region(region, 10, 'x') }.to raise_error(TypeError)
    expect { girl.find_similar_region(region, 'x') }.to raise_error(TypeError)

    region.destroy!
    expect { girl.find_similar_region(region) }.to raise_error(Magick::DestroyedImageError)
  end

  def test_flip
    expect do
      res = @img.flip
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
  end

  def test_flip!
    expect do
      res = @img.flip!
      expect(res).to be(@img)
    end.not_to raise_error
  end

  def test_flop
    expect do
      res = @img.flop
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
  end

  def test_flop!
    expect do
      res = @img.flop!
      expect(res).to be(@img)
    end.not_to raise_error
  end

  def test_frame
    expect do
      res = @img.frame
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.frame(50) }.not_to raise_error
    expect { @img.frame(50, 50) }.not_to raise_error
    expect { @img.frame(50, 50, 25) }.not_to raise_error
    expect { @img.frame(50, 50, 25, 25) }.not_to raise_error
    expect { @img.frame(50, 50, 25, 25, 6) }.not_to raise_error
    expect { @img.frame(50, 50, 25, 25, 6, 6) }.not_to raise_error
    expect { @img.frame(50, 50, 25, 25, 6, 6, 'red') }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { @img.frame(50, 50, 25, 25, 6, 6, red) }.not_to raise_error
    expect { @img.frame(50, 50, 25, 25, 6, 6, 2) }.to raise_error(TypeError)
    expect { @img.frame(50, 50, 25, 25, 6, 6, red, 2) }.to raise_error(ArgumentError)
  end

  def test_fx
    expect { @img.fx('1/2') }.not_to raise_error
    expect { @img.fx('1/2', Magick::BlueChannel) }.not_to raise_error
    expect { @img.fx('1/2', Magick::BlueChannel, Magick::RedChannel) }.not_to raise_error
    expect { @img.fx }.to raise_error(ArgumentError)
    expect { @img.fx(Magick::BlueChannel) }.to raise_error(ArgumentError)
    expect { @img.fx(1) }.to raise_error(TypeError)
    expect { @img.fx('1/2', 1) }.to raise_error(TypeError)
  end

  def test_gamma_channel
    expect do
      res = @img.gamma_channel(0.8)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.gamma_channel }.to raise_error(ArgumentError)
    expect { @img.gamma_channel(0.8, Magick::RedChannel) }.not_to raise_error
    expect { @img.gamma_channel(0.8, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.gamma_channel(0.8, Magick::RedChannel, 2) }.to raise_error(TypeError)
  end

  def test_function_channel
    img = Magick::Image.read('gradient:') { self.size = '20x600' }
    img = img.first
    img.rotate!(90)
    expect { img.function_channel Magick::PolynomialFunction, 0.33 }.not_to raise_error
    expect { img.function_channel Magick::PolynomialFunction, 4, -1.5 }.not_to raise_error
    expect { img.function_channel Magick::PolynomialFunction, 4, -4, 1 }.not_to raise_error
    expect { img.function_channel Magick::PolynomialFunction, -25, 53, -36, 8.3, 0.2 }.not_to raise_error

    expect { img.function_channel Magick::SinusoidFunction, 1 }.not_to raise_error
    expect { img.function_channel Magick::SinusoidFunction, 1, 90 }.not_to raise_error
    expect { img.function_channel Magick::SinusoidFunction, 5, 90, 0.25, 0.75 }.not_to raise_error

    expect { img.function_channel Magick::ArcsinFunction, 1 }.not_to raise_error
    expect { img.function_channel Magick::ArcsinFunction, 0.5 }.not_to raise_error
    expect { img.function_channel Magick::ArcsinFunction, 0.4, 0.7 }.not_to raise_error
    expect { img.function_channel Magick::ArcsinFunction, 0.5, 0.5, 0.5, 0.5 }.not_to raise_error

    expect { img.function_channel Magick::ArctanFunction, 1 }.not_to raise_error
    expect { img.function_channel Magick::ArctanFunction, 10, 0.7 }.not_to raise_error
    expect { img.function_channel Magick::ArctanFunction, 5, 0.7, 1.2 }.not_to raise_error
    expect { img.function_channel Magick::ArctanFunction, 15, 0.7, 0.5, 0.75 }.not_to raise_error

    # with channel args
    expect { img.function_channel Magick::PolynomialFunction, 0.33, Magick::RedChannel }.not_to raise_error
    expect { img.function_channel Magick::SinusoidFunction, 1, Magick::RedChannel, Magick::BlueChannel }.not_to raise_error

    # invalid args
    expect { img.function_channel }.to raise_error(ArgumentError)
    expect { img.function_channel 1 }.to raise_error(TypeError)
    expect { img.function_channel Magick::PolynomialFunction }.to raise_error(ArgumentError)
    expect { img.function_channel Magick::PolynomialFunction, [] }.to raise_error(TypeError)
    expect { img.function_channel Magick::SinusoidFunction, 5, 90, 0.25, 0.75, 0.1 }.to raise_error(ArgumentError)
    expect { img.function_channel Magick::ArcsinFunction, 0.5, 0.5, 0.5, 0.5, 0.1 }.to raise_error(ArgumentError)
    expect { img.function_channel Magick::ArctanFunction, 15, 0.7, 0.5, 0.75, 0.1 }.to raise_error(ArgumentError)
  end

  def test_gramma_correct
    expect { @img.gamma_correct }.to raise_error(ArgumentError)
    expect do
      res = @img.gamma_correct(0.8)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.gamma_correct(0.8, 0.9) }.not_to raise_error
    expect { @img.gamma_correct(0.8, 0.9, 1.0) }.not_to raise_error
    expect { @img.gamma_correct(0.8, 0.9, 1.0, 1.1) }.not_to raise_error
    # too many arguments
    expect { @img.gamma_correct(0.8, 0.9, 1.0, 1.1, 2) }.to raise_error(ArgumentError)
  end

  def test_gaussian_blur
    expect do
      res = @img.gaussian_blur
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.gaussian_blur(0.0) }.not_to raise_error
    expect { @img.gaussian_blur(0.0, 3.0) }.not_to raise_error
    # sigma must be != 0.0
    expect { @img.gaussian_blur(1.0, 0.0) }.to raise_error(ArgumentError)
    expect { @img.gaussian_blur(1.0, 3.0, 2) }.to raise_error(ArgumentError)
  end

  def test_gaussian_blur_channel
    expect do
      res = @img.gaussian_blur_channel
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.gaussian_blur_channel(0.0) }.not_to raise_error
    expect { @img.gaussian_blur_channel(0.0, 3.0) }.not_to raise_error
    expect { @img.gaussian_blur_channel(0.0, 3.0, Magick::RedChannel) }.not_to raise_error
    expect { @img.gaussian_blur_channel(0.0, 3.0, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.gaussian_blur_channel(0.0, 3.0, Magick::RedChannel, 2) }.to raise_error(TypeError)
  end

  def test_get_exif_by_entry
    expect do
      res = @img.get_exif_by_entry
      expect(res).to be_instance_of(Array)
    end.not_to raise_error
  end

  def test_get_exif_by_number
    expect do
      res = @img.get_exif_by_number
      expect(res).to be_instance_of(Hash)
    end.not_to raise_error
  end

  def test_get_pixels
    expect do
      pixels = @img.get_pixels(0, 0, @img.columns, 1)
      expect(pixels).to be_instance_of(Array)
      expect(pixels.length).to eq(@img.columns)
      assert_block do
        pixels.all? { |p| p.is_a? Magick::Pixel }
      end
    end.not_to raise_error
    expect { @img.get_pixels(0,  0, -1, 1) }.to raise_error(RangeError)
    expect { @img.get_pixels(0,  0, @img.columns, -1) }.to raise_error(RangeError)
    expect { @img.get_pixels(0,  0, @img.columns + 1, 1) }.to raise_error(RangeError)
    expect { @img.get_pixels(0,  0, @img.columns, @img.rows + 1) }.to raise_error(RangeError)
  end

  def test_gray?
    gray = Magick::Image.new(20, 20) { self.background_color = 'gray50' }
    assert(gray.gray?)
    red = Magick::Image.new(20, 20) { self.background_color = 'red' }
    assert(!red.gray?)
  end

  def test_histogram?
    expect { @img.histogram? }.not_to raise_error
    assert(@img.histogram?)
  end

  def test_implode
    expect do
      res = @img.implode(0.5)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.implode(0.5, 0.5) }.to raise_error(ArgumentError)
  end

  def test_import_pixels
    pixels = @img.export_pixels(0, 0, @img.columns, 1, 'RGB')
    expect do
      res = @img.import_pixels(0, 0, @img.columns, 1, 'RGB', pixels)
      expect(res).to be(@img)
    end.not_to raise_error
    expect { @img.import_pixels }.to raise_error(ArgumentError)
    expect { @img.import_pixels(0) }.to raise_error(ArgumentError)
    expect { @img.import_pixels(0, 0) }.to raise_error(ArgumentError)
    expect { @img.import_pixels(0, 0, @img.columns) }.to raise_error(ArgumentError)
    expect { @img.import_pixels(0, 0, @img.columns, 1) }.to raise_error(ArgumentError)
    expect { @img.import_pixels(0, 0, @img.columns, 1, 'RGB') }.to raise_error(ArgumentError)
    expect { @img.import_pixels('x', 0, @img.columns, 1, 'RGB', pixels) }.to raise_error(TypeError)
    expect { @img.import_pixels(0, 'x', @img.columns, 1, 'RGB', pixels) }.to raise_error(TypeError)
    expect { @img.import_pixels(0, 0, 'x', 1, 'RGB', pixels) }.to raise_error(TypeError)
    expect { @img.import_pixels(0, 0, @img.columns, 'x', 'RGB', pixels) }.to raise_error(TypeError)
    expect { @img.import_pixels(0, 0, @img.columns, 1, [2], pixels) }.to raise_error(TypeError)
    expect { @img.import_pixels(-1, 0, @img.columns, 1, 'RGB', pixels) }.to raise_error(ArgumentError)
    expect { @img.import_pixels(0, -1, @img.columns, 1, 'RGB', pixels) }.to raise_error(ArgumentError)
    expect { @img.import_pixels(0, 0, -1, 1, 'RGB', pixels) }.to raise_error(ArgumentError)
    expect { @img.import_pixels(0, 0, @img.columns, -1, 'RGB', pixels) }.to raise_error(ArgumentError)

    # pixel array is too small
    expect { @img.import_pixels(0, 0, @img.columns, 2, 'RGB', pixels) }.to raise_error(ArgumentError)
    # pixel array doesn't contain a multiple of the map length
    pixels.shift
    expect { @img.import_pixels(0, 0, @img.columns, 1, 'RGB', pixels) }.to raise_error(ArgumentError)
  end

  def test_level
    expect do
      res = @img.level
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.level(0.0) }.not_to raise_error
    expect { @img.level(0.0, 1.0) }.not_to raise_error
    expect { @img.level(0.0, 1.0, Magick::QuantumRange) }.not_to raise_error
    expect { @img.level(0.0, 1.0, Magick::QuantumRange, 2) }.to raise_error(ArgumentError)
    expect { @img.level('x') }.to raise_error(ArgumentError)
    expect { @img.level(0.0, 'x') }.to raise_error(ArgumentError)
    expect { @img.level(0.0, 1.0, 'x') }.to raise_error(ArgumentError)
  end

  # Ensure that #level properly swaps old-style arg list
  def test_level2
    img1 = @img.level(10, 2, 200)
    img2 = @img.level(10, 200, 2)
    expect(img1).to eq(img2)

    # Ensure that level2 uses new arg order
    img1 = @img.level2(10, 200, 2)
    expect(img1).to eq(img2)

    expect { @img.level2 }.not_to raise_error
    expect { @img.level2(10) }.not_to raise_error
    expect { @img.level2(10, 10) }.not_to raise_error
    expect { @img.level2(10, 10, 10) }.not_to raise_error
    expect { @img.level2(10, 10, 10, 10) }.to raise_error(ArgumentError)
  end

  def test_level_channel
    expect { @img.level_channel }.to raise_error(ArgumentError)
    expect do
      res = @img.level_channel(Magick::RedChannel)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error

    expect { @img.level_channel(Magick::RedChannel, 0.0) }.not_to raise_error
    expect { @img.level_channel(Magick::RedChannel, 0.0, 1.0) }.not_to raise_error
    expect { @img.level_channel(Magick::RedChannel, 0.0, 1.0, Magick::QuantumRange) }.not_to raise_error

    expect { @img.level_channel(Magick::RedChannel, 0.0, 1.0, Magick::QuantumRange, 2) }.to raise_error(ArgumentError)
    expect { @img.level_channel(2) }.to raise_error(TypeError)
    expect { @img.level_channel(Magick::RedChannel, 'x') }.to raise_error(TypeError)
    expect { @img.level_channel(Magick::RedChannel, 0.0, 'x') }.to raise_error(TypeError)
    expect { @img.level_channel(Magick::RedChannel, 0.0, 1.0, 'x') }.to raise_error(TypeError)
  end

  def test_level_colors
    res = nil
    expect do
      res = @img.level_colors
    end.not_to raise_error
    expect(res).to be_instance_of(Magick::Image)
    expect(res).not_to be(@img)

    expect { @img.level_colors('black') }.not_to raise_error
    expect { @img.level_colors('black', Magick::Pixel.new(0, 0, 0)) }.not_to raise_error
    expect { @img.level_colors(Magick::Pixel.new(0, 0, 0), Magick::Pixel.new(Magick::QuantumRange, Magick::QuantumRange, Magick::QuantumRange)) }.not_to raise_error
    expect { @img.level_colors('black', 'white') }.not_to raise_error
    expect { @img.level_colors('black', 'white', false) }.not_to raise_error

    expect { @img.level_colors('black', 'white', false, 1) }.to raise_error(TypeError)
    expect { @img.level_colors([]) }.to raise_error(TypeError)
    expect { @img.level_colors('xxx') }.to raise_error(ArgumentError)
  end

  def test_levelize_channel
    res = nil
    expect do
      res = @img.levelize_channel(0, Magick::QuantumRange)
    end.not_to raise_error
    expect(res).to be_instance_of(Magick::Image)
    expect(res).not_to be(@img)

    expect { @img.levelize_channel(0) }.not_to raise_error
    expect { @img.levelize_channel(0, Magick::QuantumRange) }.not_to raise_error
    expect { @img.levelize_channel(0, Magick::QuantumRange, 0.5) }.not_to raise_error
    expect { @img.levelize_channel(0, Magick::QuantumRange, 0.5, Magick::RedChannel) }.not_to raise_error
    expect { @img.levelize_channel(0, Magick::QuantumRange, 0.5, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error

    expect { @img.levelize_channel(0, Magick::QuantumRange, 0.5, 1, Magick::RedChannel) }.to raise_error(TypeError)
    expect { @img.levelize_channel }.to raise_error(ArgumentError)
  end

  #     def test_liquid_rescale
  #       begin
  #         @img.liquid_rescale(15,15)
  #       rescue NotImplementedError
  #         puts "liquid_rescale not implemented."
  #         return
  #       end
  #
  #       res = nil
  #       expect do
  #         res = @img.liquid_rescale(15, 15)
  #       end.not_to raise_error
  #       expect(res.columns).to eq(15)
  #       expect(res.rows).to eq(15)
  #       expect { @img.liquid_rescale(15, 15, 0, 0) }.not_to raise_error
  #       expect { @img.liquid_rescale(15) }.to raise_error(ArgumentError)
  #       expect { @img.liquid_rescale(15, 15, 0, 0, 0) }.to raise_error(ArgumentError)
  #       expect { @img.liquid_rescale([], 15) }.to raise_error(TypeError)
  #       expect { @img.liquid_rescale(15, []) }.to raise_error(TypeError)
  #       expect { @img.liquid_rescale(15, 15, []) }.to raise_error(TypeError)
  #       expect { @img.liquid_rescale(15, 15, 0, []) }.to raise_error(TypeError)
  #     end

  def test_magnify
    expect do
      res = @img.magnify
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error

    res = @img.magnify!
    expect(res).to be(@img)
  end

  def test_marshal
    img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    d = nil
    img2 = nil
    expect { d = Marshal.dump(img) }.not_to raise_error
    expect { img2 = Marshal.load(d) }.not_to raise_error
    expect(img2).to eq(img)
  end

  def test_mask
    cimg = Magick::Image.new(10, 10)
    expect { @img.mask(cimg) }.not_to raise_error
    res = nil
    expect { res = @img.mask }.not_to raise_error
    assert_not_nil(res)
    expect(res).not_to be(cimg)
    expect(res.columns).to eq(20)
    expect(res.rows).to eq(20)

    expect { @img.mask(cimg, 'x') }.to raise_error(ArgumentError)
    # mask expects an Image and calls `cur_image'
    expect { @img.mask = 2 }.to raise_error(NoMethodError)

    img = @img.copy.freeze
    expect { img.mask cimg }.to raise_error(FreezeError)

    @img.destroy!
    expect { @img.mask cimg }.to raise_error(Magick::DestroyedImageError)
  end

  def test_matte_fill_to_border
    expect do
      res = @img.matte_fill_to_border(@img.columns / 2, @img.rows / 2)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.matte_fill_to_border(@img.columns, @img.rows) }.not_to raise_error
    expect { @img.matte_fill_to_border(@img.columns + 1, @img.rows) }.to raise_error(ArgumentError)
    expect { @img.matte_fill_to_border(@img.columns, @img.rows + 1) }.to raise_error(ArgumentError)
  end

  def test_matte_floodfill
    expect do
      res = @img.matte_floodfill(@img.columns / 2, @img.rows / 2)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.matte_floodfill(@img.columns, @img.rows) }.not_to raise_error

    Magick::PaintMethod.values do |method|
      next if [Magick::FillToBorderMethod, Magick::FloodfillMethod].include?(method)

      expect { @img.matte_flood_fill('blue', Magick::TransparentAlpha, @img.columns, @img.rows, method) }.to raise_error(ArgumentError)
    end
    expect { @img.matte_floodfill(@img.columns + 1, @img.rows) }.to raise_error(ArgumentError)
    expect { @img.matte_floodfill(@img.columns, @img.rows + 1) }.to raise_error(ArgumentError)
    expect { @img.matte_flood_fill('blue', @img.columns, @img.rows, Magick::FloodfillMethod, alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { @img.matte_flood_fill('blue', @img.columns, @img.rows, Magick::FloodfillMethod, wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
  end

  def test_matte_replace
    expect do
      res = @img.matte_replace(@img.columns / 2, @img.rows / 2)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
  end

  def test_matte_reset!
    expect do
      res = @img.matte_reset!
      expect(res).to be(@img)
    end.not_to raise_error
  end

  def test_median_filter
    expect do
      res = @img.median_filter
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.median_filter(0.5) }.not_to raise_error
    expect { @img.median_filter(0.5, 'x') }.to raise_error(ArgumentError)
    expect { @img.median_filter('x') }.to raise_error(TypeError)
  end

  def test_minify
    expect do
      res = @img.minify
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error

    res = @img.minify!
    expect(res).to be(@img)
  end

  def test_modulate
    expect do
      res = @img.modulate
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.modulate(0.5) }.not_to raise_error
    expect { @img.modulate(0.5, 0.5) }.not_to raise_error
    expect { @img.modulate(0.5, 0.5, 0.5) }.not_to raise_error
    expect { @img.modulate(0.0, 0.5, 0.5) }.to raise_error(ArgumentError)
    expect { @img.modulate(0.5, 0.5, 0.5, 0.5) }.to raise_error(ArgumentError)
    expect { @img.modulate('x', 0.5, 0.5) }.to raise_error(TypeError)
    expect { @img.modulate(0.5, 'x', 0.5) }.to raise_error(TypeError)
    expect { @img.modulate(0.5, 0.5, 'x') }.to raise_error(TypeError)
  end

  def test_monochrome?
    #       assert_block { @img.monochrome? }
    @img.pixel_color(0, 0, 'red')
    assert_block { !@img.monochrome? }
  end

  def test_motion_blur
    expect do
      res = @img.motion_blur(1.0, 7.0, 180)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.motion_blur(1.0, 0.0, 180) }.to raise_error(ArgumentError)
    expect { @img.motion_blur(1.0, -1.0, 180) }.not_to raise_error
  end

  def test_negate
    expect do
      res = @img.negate
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.negate(true) }.not_to raise_error
    expect { @img.negate(true, 2) }.to raise_error(ArgumentError)
  end

  def test_negate_channel
    expect do
      res = @img.negate_channel
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.negate_channel(true) }.not_to raise_error
    expect { @img.negate_channel(true, Magick::RedChannel) }.not_to raise_error
    expect { @img.negate_channel(true, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.negate_channel(true, Magick::RedChannel, 2) }.to raise_error(TypeError)
  end

  def test_normalize
    expect do
      res = @img.normalize
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
  end

  def test_normalize_channel
    expect do
      res = @img.normalize_channel
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.normalize_channel(Magick::RedChannel) }.not_to raise_error
    expect { @img.normalize_channel(Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.normalize_channel(Magick::RedChannel, 2) }.to raise_error(TypeError)
  end

  def test_oil_paint
    expect do
      res = @img.oil_paint
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.oil_paint(2.0) }.not_to raise_error
    expect { @img.oil_paint(2.0, 1.0) }.to raise_error(ArgumentError)
  end

  def test_opaque
    expect do
      res = @img.opaque('white', 'red')
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    blue = Magick::Pixel.new(0, 0, Magick::QuantumRange)
    expect { @img.opaque(red, blue) }.not_to raise_error
    expect { @img.opaque(red, 2) }.to raise_error(TypeError)
    expect { @img.opaque(2, blue) }.to raise_error(TypeError)
  end

  def test_opaque_channel
    res = nil
    expect { res = @img.opaque_channel('white', 'red') }.not_to raise_error
    assert_not_nil(res)
    expect(res).to be_instance_of(Magick::Image)
    expect(@img).not_to be(res)
    expect { @img.opaque_channel('red', 'blue', true) }.not_to raise_error
    expect { @img.opaque_channel('red', 'blue', true, 50) }.not_to raise_error
    expect { @img.opaque_channel('red', 'blue', true, 50, Magick::RedChannel) }.not_to raise_error
    expect { @img.opaque_channel('red', 'blue', true, 50, Magick::RedChannel, Magick::GreenChannel) }.not_to raise_error
    expect do
      @img.opaque_channel('red', 'blue', true, 50, Magick::RedChannel, Magick::GreenChannel, Magick::BlueChannel)
    end.not_to raise_error

    expect { @img.opaque_channel('red', 'blue', true, 50, 50) }.to raise_error(TypeError)
    expect { @img.opaque_channel('red', 'blue', true, []) }.to raise_error(TypeError)
    expect { @img.opaque_channel('red') }.to raise_error(ArgumentError)
    expect { @img.opaque_channel('red', 'blue', true, -0.1) }.to raise_error(ArgumentError)
    expect { @img.opaque_channel('red', []) }.to raise_error(TypeError)
  end

  def test_opaque?
    expect do
      assert_block { @img.opaque? }
    end.not_to raise_error
    @img.alpha(Magick::TransparentAlphaChannel)
    assert_block { !@img.opaque? }
  end

  def test_ordered_dither
    expect do
      res = @img.ordered_dither
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.ordered_dither('3x3') }.not_to raise_error
    expect { @img.ordered_dither(2) }.not_to raise_error
    expect { @img.ordered_dither(3) }.not_to raise_error
    expect { @img.ordered_dither(4) }.not_to raise_error
    expect { @img.ordered_dither(5) }.to raise_error(ArgumentError)
    expect { @img.ordered_dither(2, 1) }.to raise_error(ArgumentError)
  end

  def test_paint_transparent
    res = nil
    expect { res = @img.paint_transparent('red') }.not_to raise_error
    assert_not_nil(res)
    expect(res).to be_instance_of(Magick::Image)
    expect(@img).not_to be(res)
    expect { @img.paint_transparent('red', Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { @img.paint_transparent('red', alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { @img.paint_transparent('red', wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { @img.paint_transparent('red', Magick::TransparentAlpha, true) }.to raise_error(ArgumentError)
    expect { @img.paint_transparent('red', true, alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { @img.paint_transparent('red', true, wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { @img.paint_transparent('red', true, alpha: Magick::TransparentAlpha, extra: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { @img.paint_transparent('red', Magick::TransparentAlpha, true, 50) }.to raise_error(ArgumentError)
    expect { @img.paint_transparent('red', true, 50, alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { @img.paint_transparent('red', true, 50, wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)

    # Too many arguments
    expect { @img.paint_transparent('red', true, 50, 50, 50) }.to raise_error(ArgumentError)
    # Not enough
    expect { @img.paint_transparent }.to raise_error(ArgumentError)
    expect { @img.paint_transparent('red', true, [], alpha: Magick::TransparentAlpha) }.to raise_error(TypeError)
    expect { @img.paint_transparent(50) }.to raise_error(TypeError)
  end

  def test_palette?
    img = Magick::Image.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    expect do
      assert_block { !img.palette? }
    end.not_to raise_error
    img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    assert_block { img.palette? }
  end

  def test_pixel_color
    expect do
      res = @img.pixel_color(0, 0)
      expect(res).to be_instance_of(Magick::Pixel)
    end.not_to raise_error
    res = @img.pixel_color(0, 0)
    expect(res.to_color).to eq(@img.background_color)
    res = @img.pixel_color(0, 0, 'red')
    expect(res.to_color).to eq('white')
    res = @img.pixel_color(0, 0)
    expect(res.to_color).to eq('red')

    blue = Magick::Pixel.new(0, 0, Magick::QuantumRange)
    expect { @img.pixel_color(0, 0, blue) }.not_to raise_error
    # If args are out-of-bounds return the background color
    img = Magick::Image.new(10, 10) { self.background_color = 'blue' }
    expect(img.pixel_color(50, 50).to_color).to eq('blue')

    expect do
      @img.class_type = Magick::PseudoClass
      res = @img.pixel_color(0, 0, 'red')
      expect(res.to_color).to eq('blue')
    end.not_to raise_error
  end

  def test_polaroid
    expect { @img.polaroid }.not_to raise_error
    expect { @img.polaroid(5) }.not_to raise_error
    expect(@img.polaroid).to be_instance_of(Magick::Image)
    expect { @img.polaroid('x') }.to raise_error(TypeError)
    expect { @img.polaroid(5, 'x') }.to raise_error(ArgumentError)
  end

  def test_posterize
    expect do
      res = @img.posterize
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.posterize(5) }.not_to raise_error
    expect { @img.posterize(5, true) }.not_to raise_error
    expect { @img.posterize(5, true, 'x') }.to raise_error(ArgumentError)
  end
end

if $PROGRAM_NAME == __FILE__
  IMAGES_DIR = '../doc/ex/images'
  FILES = Dir[IMAGES_DIR + '/Button_*.gif']
  Test::Unit::UI::Console::TestRunner.run(Image2UT)
end
