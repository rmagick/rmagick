require 'rmagick'
require 'minitest/autorun'

class Image1_UT < Minitest::Test
  def setup
    @img = Magick::Image.new(20, 20)
  end

  def test_read_inline
    img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    blob = img.to_blob
    encoded = [blob].pack('m*')
    res = Magick::Image.read_inline(encoded)
    expect(res).to be_instance_of(Array)
    expect(res[0]).to be_instance_of(Magick::Image)
    expect(res[0]).to eq(img)
    expect { Magick::Image.read(nil) }.to raise_error(ArgumentError)
    expect { Magick::Image.read("") }.to raise_error(ArgumentError)
  end

  def test_spaceship
    img0 = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    img1 = Magick::Image.read(IMAGES_DIR + '/Button_1.gif').first
    sig0 = img0.signature
    sig1 = img1.signature
    # since <=> is based on the signature, the images should
    # have the same relationship to each other as their
    # signatures have to each other.
    expect(img0 <=> img1).to eq(sig0 <=> sig1)
    expect(img1 <=> img0).to eq(sig1 <=> sig0)
    expect(img0).to eq(img0)
    assert_not_equal(img0, img1)
    assert_nil(img0 <=> nil)
  end

  def test_adaptive_blur
    expect do
      res = @img.adaptive_blur
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.adaptive_blur(2) }.not_to raise_error
    expect { @img.adaptive_blur(3, 2) }.not_to raise_error
    expect { @img.adaptive_blur(3, 2, 2) }.to raise_error(ArgumentError)
  end

  def test_adaptive_blur_channel
    expect do
      res = @img.adaptive_blur_channel
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.adaptive_blur_channel(2) }.not_to raise_error
    expect { @img.adaptive_blur_channel(3, 2) }.not_to raise_error
    expect { @img.adaptive_blur_channel(3, 2, Magick::RedChannel) }.not_to raise_error
    expect { @img.adaptive_blur_channel(3, 2, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.adaptive_blur_channel(3, 2, 2) }.to raise_error(TypeError)
  end

  def test_adaptive_resize
    expect do
      res = @img.adaptive_resize(10, 10)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.adaptive_resize(2) }.not_to raise_error
    expect { @img.adaptive_resize(-1.0) }.to raise_error(ArgumentError)
    expect { @img.adaptive_resize(10, 10, 10) }.to raise_error(ArgumentError)
    expect { @img.adaptive_resize }.to raise_error(ArgumentError)
    expect { @img.adaptive_resize(Float::MAX) }.to raise_error(RangeError)
  end

  def test_adaptive_sharpen
    expect do
      res = @img.adaptive_sharpen
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.adaptive_sharpen(2) }.not_to raise_error
    expect { @img.adaptive_sharpen(3, 2) }.not_to raise_error
    expect { @img.adaptive_sharpen(3, 2, 2) }.to raise_error(ArgumentError)
  end

  def test_adaptive_sharpen_channel
    expect do
      res = @img.adaptive_sharpen_channel
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.adaptive_sharpen_channel(2) }.not_to raise_error
    expect { @img.adaptive_sharpen_channel(3, 2) }.not_to raise_error
    expect { @img.adaptive_sharpen_channel(3, 2, Magick::RedChannel) }.not_to raise_error
    expect { @img.adaptive_sharpen_channel(3, 2, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.adaptive_sharpen_channel(3, 2, 2) }.to raise_error(TypeError)
  end

  def test_adaptive_threshold
    expect do
      res = @img.adaptive_threshold
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.adaptive_threshold(2) }.not_to raise_error
    expect { @img.adaptive_threshold(2, 4) }.not_to raise_error
    expect { @img.adaptive_threshold(2, 4, 1) }.not_to raise_error
    expect { @img.adaptive_threshold(2, 4, 1, 2) }.to raise_error(ArgumentError)
  end

  def test_add_compose_mask
    mask = Magick::Image.new(20, 20)
    expect { @img.add_compose_mask(mask) }.not_to raise_error
    expect { @img.delete_compose_mask }.not_to raise_error
    expect { @img.add_compose_mask(mask) }.not_to raise_error
    expect { @img.add_compose_mask(mask) }.not_to raise_error
    expect { @img.delete_compose_mask }.not_to raise_error
    expect { @img.delete_compose_mask }.not_to raise_error

    mask = Magick::Image.new(10, 10)
    expect { @img.add_compose_mask(mask) }.to raise_error(ArgumentError)
  end

  def test_add_noise
    Magick::NoiseType.values do |noise|
      expect { @img.add_noise(noise) }.not_to raise_error
    end
    expect { @img.add_noise(0) }.to raise_error(TypeError)
  end

  def test_add_noise_channel
    expect { @img.add_noise_channel(Magick::UniformNoise) }.not_to raise_error
    expect { @img.add_noise_channel(Magick::UniformNoise, Magick::RedChannel) }.not_to raise_error
    expect { @img.add_noise_channel(Magick::GaussianNoise, Magick::BlueChannel) }.not_to raise_error
    expect { @img.add_noise_channel(Magick::ImpulseNoise, Magick::GreenChannel) }.not_to raise_error
    expect { @img.add_noise_channel(Magick::LaplacianNoise, Magick::RedChannel, Magick::GreenChannel) }.not_to raise_error
    expect { @img.add_noise_channel(Magick::PoissonNoise, Magick::RedChannel, Magick::GreenChannel, Magick::BlueChannel) }.not_to raise_error

    # Not a NoiseType
    expect { @img.add_noise_channel(1) }.to raise_error(TypeError)
    # Not a ChannelType
    expect { @img.add_noise_channel(Magick::UniformNoise, Magick::RedChannel, 1) }.to raise_error(TypeError)
    # Too few arguments
    expect { @img.add_noise_channel }.to raise_error(ArgumentError)
  end

  def test_add_delete_profile
    img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    expect { img.add_profile(File.join(__dir__, 'cmyk.icm')) }.not_to raise_error
    # expect { img.add_profile(File.join(__dir__, 'srgb.icm')) }.to raise_error(Magick::ImageMagickError)

    img.each_profile { |name, _value| expect(name).to eq('icc') }
    expect { img.delete_profile('icc') }.not_to raise_error
  end

  def test_affine_matrix
    affine = Magick::AffineMatrix.new(1, Math::PI / 6, Math::PI / 6, 1, 0, 0)
    expect { @img.affine_transform(affine) }.not_to raise_error
    expect { @img.affine_transform(0) }.to raise_error(TypeError)
    res = @img.affine_transform(affine)
    expect(res).to be_instance_of(Magick::Image)
  end

  # test alpha backward compatibility. Image#alpha w/o arguments acts like alpha?
  def test_alpha_compat
    expect { @img.alpha }.not_to raise_error
    assert !@img.alpha
    expect { @img.alpha Magick::ActivateAlphaChannel }.not_to raise_error
    assert @img.alpha
  end

  def test_alpha
    expect { @img.alpha? }.not_to raise_error
    assert !@img.alpha?
    expect { @img.alpha Magick::ActivateAlphaChannel }.not_to raise_error
    assert @img.alpha?
    expect { @img.alpha Magick::DeactivateAlphaChannel }.not_to raise_error
    assert !@img.alpha?
    expect { @img.alpha Magick::OpaqueAlphaChannel }.not_to raise_error
    expect { @img.alpha Magick::SetAlphaChannel }.not_to raise_error
    expect { @img.alpha Magick::SetAlphaChannel, Magick::OpaqueAlphaChannel }.to raise_error(ArgumentError)
    @img.freeze
    expect { @img.alpha Magick::SetAlphaChannel }.to raise_error(FreezeError)
  end

  def test_aref
    img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    assert_nil(img[nil])
    assert_nil(img['label'])
    assert_match(/^Creator: PolyView/, img[:comment])
  end

  def test_aset
    @img['label'] = 'foobarbaz'
    @img[:comment] = 'Hello world'
    expect(@img['label']).to eq('foobarbaz')
    expect(@img['comment']).to eq('Hello world')
    expect { @img[nil] = 'foobarbaz' }.not_to raise_error
  end

  def test_auto_gamma
    res = nil
    expect { res = @img.auto_gamma_channel }.not_to raise_error
    expect(res).to be_instance_of(Magick::Image)
    assert_not_same(@img, res)
    expect { res = @img.auto_gamma_channel Magick::RedChannel }.not_to raise_error
    expect { res = @img.auto_gamma_channel Magick::RedChannel, Magick::BlueChannel }.not_to raise_error
    expect { @img.auto_gamma_channel(1) }.to raise_error(TypeError)
  end

  def test_auto_level
    res = nil
    expect { res = @img.auto_level_channel }.not_to raise_error
    expect(res).to be_instance_of(Magick::Image)
    assert_not_same(@img, res)
    expect { res = @img.auto_level_channel Magick::RedChannel }.not_to raise_error
    expect { res = @img.auto_level_channel Magick::RedChannel, Magick::BlueChannel }.not_to raise_error
    expect { @img.auto_level_channel(1) }.to raise_error(TypeError)
  end

  def test_auto_orient
    Magick::OrientationType.values.each do |v|
      expect do
        img = Magick::Image.new(10, 10)
        img.orientation = v
        res = img.auto_orient
        expect(res).to be_instance_of(Magick::Image)
        assert_not_same(img, res)
      end.not_to raise_error
    end

    expect do
      res = @img.auto_orient!
      # When not changed, returns nil
      assert_nil(res)
    end.not_to raise_error
  end

  def test_bilevel_channel
    expect { @img.bilevel_channel }.to raise_error(ArgumentError)
    expect { @img.bilevel_channel(100) }.not_to raise_error
    expect { @img.bilevel_channel(100, Magick::RedChannel) }.not_to raise_error
    expect { @img.bilevel_channel(100, Magick::RedChannel, Magick::BlueChannel, Magick::GreenChannel, Magick::OpacityChannel) }.not_to raise_error
    expect { @img.bilevel_channel(100, Magick::CyanChannel, Magick::MagentaChannel, Magick::YellowChannel, Magick::BlackChannel) }.not_to raise_error
    expect { @img.bilevel_channel(100, Magick::GrayChannel) }.not_to raise_error
    expect { @img.bilevel_channel(100, Magick::AllChannels) }.not_to raise_error
    expect { @img.bilevel_channel(100, 2) }.to raise_error(TypeError)
    res = @img.bilevel_channel(100)
    expect(res).to be_instance_of(Magick::Image)
  end

  def test_blend
    @img2 = Magick::Image.new(20, 20) { self.background_color = 'black' }
    expect { @img.blend(@img2, 0.25) }.not_to raise_error
    res = @img.blend(@img2, 0.25)

    Magick::GravityType.values do |gravity|
      expect { @img.blend(@img2, 0.25, 0.75, gravity) }.not_to raise_error
      expect { @img.blend(@img2, 0.25, 0.75, gravity, 10) }.not_to raise_error
      expect { @img.blend(@img2, 0.25, 0.75, gravity, 10, 10) }.not_to raise_error
    end

    expect(res).to be_instance_of(Magick::Image)
    expect { @img.blend(@img2, '25%') }.not_to raise_error
    expect { @img.blend(@img2, 0.25, 0.75) }.not_to raise_error
    expect { @img.blend(@img2, '25%', '75%') }.not_to raise_error
    expect { @img.blend }.to raise_error(ArgumentError)
    expect { @img.blend(@img2, 'x') }.to raise_error(ArgumentError)
    expect { @img.blend(@img2, 0.25, []) }.to raise_error(TypeError)
    expect { @img.blend(@img2, 0.25, 0.75, 'x') }.to raise_error(TypeError)
    expect { @img.blend(@img2, 0.25, 0.75, Magick::CenterGravity, 'x') }.to raise_error(TypeError)
    expect { @img.blend(@img2, 0.25, 0.75, Magick::CenterGravity, 10, []) }.to raise_error(TypeError)

    @img2.destroy!
    expect { @img.blend(@img2, '25%') }.to raise_error(Magick::DestroyedImageError)
  end

  def test_blue_shift
    assert_not_same(@img, @img.blue_shift)
    assert_not_same(@img, @img.blue_shift(2.0))
    expect { @img.blue_shift('x') }.to raise_error(TypeError)
    expect { @img.blue_shift(2, 2) }.to raise_error(ArgumentError)
  end

  def test_blur_channel
    expect { @img.blur_channel }.not_to raise_error
    expect { @img.blur_channel(1) }.not_to raise_error
    expect { @img.blur_channel(1, 2) }.not_to raise_error
    expect { @img.blur_channel(1, 2, Magick::RedChannel) }.not_to raise_error
    expect { @img.blur_channel(1, 2, Magick::RedChannel, Magick::BlueChannel, Magick::GreenChannel, Magick::OpacityChannel) }.not_to raise_error
    expect { @img.blur_channel(1, 2, Magick::CyanChannel, Magick::MagentaChannel, Magick::YellowChannel, Magick::BlackChannel) }.not_to raise_error
    expect { @img.blur_channel(1, 2, Magick::GrayChannel) }.not_to raise_error
    expect { @img.blur_channel(1, 2, Magick::AllChannels) }.not_to raise_error
    expect { @img.blur_channel(1, 2, 2) }.to raise_error(TypeError)
    res = @img.blur_channel
    expect(res).to be_instance_of(Magick::Image)
  end

  def test_blur_image
    expect { @img.blur_image }.not_to raise_error
    expect { @img.blur_image(1) }.not_to raise_error
    expect { @img.blur_image(1, 2) }.not_to raise_error
    expect { @img.blur_image(1, 2, 3) }.to raise_error(ArgumentError)
    res = @img.blur_image
    expect(res).to be_instance_of(Magick::Image)
  end

  def test_black_threshold
    expect { @img.black_threshold }.to raise_error(ArgumentError)
    expect { @img.black_threshold(50) }.not_to raise_error
    expect { @img.black_threshold(50, 50) }.not_to raise_error
    expect { @img.black_threshold(50, 50, 50) }.not_to raise_error
    expect { @img.black_threshold(50, 50, 50, 50) }.to raise_error(ArgumentError)
    expect { @img.black_threshold(50, 50, 50, alpha: 50) }.not_to raise_error
    expect { @img.black_threshold(50, 50, 50, wrong: 50) }.to raise_error(ArgumentError)
    expect { @img.black_threshold(50, 50, 50, alpha: 50, extra: 50) }.to raise_error(ArgumentError)
    expect { @img.black_threshold(50, 50, 50, 50, 50) }.to raise_error(ArgumentError)
    res = @img.black_threshold(50)
    expect(res).to be_instance_of(Magick::Image)
  end

  def test_border
    expect { @img.border(2, 2, 'red') }.not_to raise_error
    expect { @img.border!(2, 2, 'red') }.not_to raise_error
    res = @img.border(2, 2, 'red')
    expect(res).to be_instance_of(Magick::Image)
    @img.freeze
    expect { @img.border!(2, 2, 'red') }.to raise_error(FreezeError)
  end

  def test_capture
    # expect { Magick::Image.capture }.not_to raise_error
    # expect { Magick::Image.capture(true) }.not_to raise_error
    # expect { Magick::Image.capture(true, true) }.not_to raise_error
    # expect { Magick::Image.capture(true, true, true) }.not_to raise_error
    # expect { Magick::Image.capture(true, true, true, true) }.not_to raise_error
    # expect { Magick::Image.capture(true, true, true, true, true) }.not_to raise_error
    expect { Magick::Image.capture(true, true, true, true, true, true) }.to raise_error(ArgumentError)
  end

  def test_change_geometry
    expect { @img.change_geometry('sss') }.to raise_error(ArgumentError)
    expect { @img.change_geometry('100x100') }.to raise_error(LocalJumpError)
    expect do
      res = @img.change_geometry('100x100') { 1 }
      expect(res).to eq(1)
    end.not_to raise_error
    expect { @img.change_geometry([]) }.to raise_error(ArgumentError)
  end

  def test_changed?
    #        assert_block { !@img.changed? }
    #        @img.pixel_color(0,0,'red')
    #        assert_block { @img.changed? }
  end

  def test_channel
    Magick::ChannelType.values do |channel|
      expect { @img.channel(channel) }.not_to raise_error
    end

    expect(@img.channel(Magick::RedChannel)).to be_instance_of(Magick::Image)
    expect { @img.channel(2) }.to raise_error(TypeError)
  end

  def test_channel_depth
    expect { @img.channel_depth }.not_to raise_error
    expect { @img.channel_depth(Magick::RedChannel) }.not_to raise_error
    expect { @img.channel_depth(Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.channel_depth(Magick::GreenChannel, Magick::OpacityChannel) }.not_to raise_error
    expect { @img.channel_depth(Magick::MagentaChannel, Magick::CyanChannel) }.not_to raise_error
    expect { @img.channel_depth(Magick::CyanChannel, Magick::BlackChannel) }.not_to raise_error
    expect { @img.channel_depth(Magick::GrayChannel) }.not_to raise_error
    expect { @img.channel_depth(2) }.to raise_error(TypeError)
    assert_kind_of(Integer, @img.channel_depth(Magick::RedChannel))
  end

  def test_channel_extrema
    expect do
      res = @img.channel_extrema
      expect(res).to be_instance_of(Array)
      expect(res.length).to eq(2)
      assert_kind_of(Integer, res[0])
      assert_kind_of(Integer, res[1])
    end.not_to raise_error
    expect { @img.channel_extrema(Magick::RedChannel) }.not_to raise_error
    expect { @img.channel_extrema(Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.channel_extrema(Magick::GreenChannel, Magick::OpacityChannel) }.not_to raise_error
    expect { @img.channel_extrema(Magick::MagentaChannel, Magick::CyanChannel) }.not_to raise_error
    expect { @img.channel_extrema(Magick::CyanChannel, Magick::BlackChannel) }.not_to raise_error
    expect { @img.channel_extrema(Magick::GrayChannel) }.not_to raise_error
    expect { @img.channel_extrema(2) }.to raise_error(TypeError)
  end

  def test_channel_mean
    expect do
      res = @img.channel_mean
      expect(res).to be_instance_of(Array)
      expect(res.length).to eq(2)
      expect(res[0]).to be_instance_of(Float)
      expect(res[1]).to be_instance_of(Float)
    end.not_to raise_error
    expect { @img.channel_mean(Magick::RedChannel) }.not_to raise_error
    expect { @img.channel_mean(Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.channel_mean(Magick::GreenChannel, Magick::OpacityChannel) }.not_to raise_error
    expect { @img.channel_mean(Magick::MagentaChannel, Magick::CyanChannel) }.not_to raise_error
    expect { @img.channel_mean(Magick::CyanChannel, Magick::BlackChannel) }.not_to raise_error
    expect { @img.channel_mean(Magick::GrayChannel) }.not_to raise_error
    expect { @img.channel_mean(2) }.to raise_error(TypeError)
  end

  def test_charcoal
    expect do
      res = @img.charcoal
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.charcoal(1.0) }.not_to raise_error
    expect { @img.charcoal(1.0, 2.0) }.not_to raise_error
    expect { @img.charcoal(1.0, 2.0, 3.0) }.to raise_error(ArgumentError)
  end

  def test_chop
    expect do
      res = @img.chop(10, 10, 10, 10)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
  end

  def test_clone
    expect do
      res = @img.clone
      expect(res).to be_instance_of(Magick::Image)
      expect(@img).to eq(res)
    end.not_to raise_error
    res = @img.clone
    expect(@img.frozen?).to eq(res.frozen?)
    @img.freeze
    res = @img.clone
    expect(@img.frozen?).to eq(res.frozen?)
  end

  def test_clut_channel
    img = Magick::Image.new(20, 20) { self.colorspace = Magick::GRAYColorspace }
    clut = Magick::Image.new(20, 1) { self.background_color = 'red' }
    res = nil
    expect { res = img.clut_channel(clut) }.not_to raise_error
    expect(res).to be(img)
    expect { img.clut_channel(clut, Magick::RedChannel) }.not_to raise_error
    expect { img.clut_channel(clut, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { img.clut_channel }.to raise_error(ArgumentError)
    expect { img.clut_channel(clut, 1, Magick::RedChannel) }.to raise_error(ArgumentError)
  end

  def test_color_fill_to_border
    expect { @img.color_fill_to_border(-1, 1, 'red') }.to raise_error(ArgumentError)
    expect { @img.color_fill_to_border(1, 100, 'red') }.to raise_error(ArgumentError)
    expect do
      res = @img.color_fill_to_border(@img.columns / 2, @img.rows / 2, 'red')
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { @img.color_fill_to_border(@img.columns / 2, @img.rows / 2, pixel) }.not_to raise_error
  end

  def test_color_floodfill
    expect { @img.color_floodfill(-1, 1, 'red') }.to raise_error(ArgumentError)
    expect { @img.color_floodfill(1, 100, 'red') }.to raise_error(ArgumentError)
    expect do
      res = @img.color_floodfill(@img.columns / 2, @img.rows / 2, 'red')
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { @img.color_floodfill(@img.columns / 2, @img.rows / 2, pixel) }.not_to raise_error
  end

  def test_color_histogram
    expect do
      res = @img.color_histogram
      expect(res).to be_instance_of(Hash)
    end.not_to raise_error
    expect do
      @img.class_type = Magick::PseudoClass
      res = @img.color_histogram
      expect(@img.class_type).to eq(Magick::PseudoClass)
      expect(res).to be_instance_of(Hash)
    end.not_to raise_error
  end

  def test_colorize
    expect do
      res = @img.colorize(0.25, 0.25, 0.25, 'red')
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.colorize(0.25, 0.25, 0.25, 0.25, 'red') }.not_to raise_error
    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { @img.colorize(0.25, 0.25, 0.25, pixel) }.not_to raise_error
    expect { @img.colorize(0.25, 0.25, 0.25, 0.25, pixel) }.not_to raise_error
    expect { @img.colorize }.to raise_error(ArgumentError)
    expect { @img.colorize(0.25) }.to raise_error(ArgumentError)
    expect { @img.colorize(0.25, 0.25) }.to raise_error(ArgumentError)
    expect { @img.colorize(0.25, 0.25, 0.25) }.to raise_error(ArgumentError)
    expect { @img.colorize(0.25, 0.25, 0.25, 'X') }.to raise_error(ArgumentError)
    # last argument must be a color name or pixel
    expect { @img.colorize(0.25, 0.25, 0.25, 0.25) }.to raise_error(TypeError)
    expect { @img.colorize(0.25, 0.25, 0.25, 0.25, 'X') }.to raise_error(ArgumentError)
    expect { @img.colorize(0.25, 0.25, 0.25, 0.25, [2]) }.to raise_error(TypeError)
  end

  def test_colormap
    # IndexError b/c @img is DirectClass
    expect { @img.colormap(0) }.to raise_error(IndexError)
    # Read PseudoClass image
    pc_img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    expect { pc_img.colormap(0) }.not_to raise_error
    ncolors = pc_img.colors
    expect { pc_img.colormap(ncolors + 1) }.to raise_error(IndexError)
    expect { pc_img.colormap(-1) }.to raise_error(IndexError)
    expect { pc_img.colormap(ncolors - 1) }.not_to raise_error
    res = pc_img.colormap(0)
    expect(res).to be_instance_of(String)

    # test 'set' operation
    expect do
      old_color = pc_img.colormap(0)
      res = pc_img.colormap(0, 'red')
      expect(res).to eq(old_color)
      res = pc_img.colormap(0)
      expect(res).to eq('red')
    end.not_to raise_error
    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { pc_img.colormap(0, pixel) }.not_to raise_error
    expect { pc_img.colormap }.to raise_error(ArgumentError)
    expect { pc_img.colormap(0, pixel, Magick::BlackChannel) }.to raise_error(ArgumentError)
    expect { pc_img.colormap(0, [2]) }.to raise_error(TypeError)
    pc_img.freeze
    expect { pc_img.colormap(0, 'red') }.to raise_error(FreezeError)
  end

  def test_color_point
    expect do
      res = @img.color_point(0, 0, 'red')
      expect(res).to be_instance_of(Magick::Image)
      assert_not_same(@img, res)
    end.not_to raise_error
    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { @img.color_point(0, 0, pixel) }.not_to raise_error
  end

  def test_color_reset!
    expect do
      res = @img.color_reset!('red')
      expect(res).to be(@img)
    end.not_to raise_error
    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { @img.color_reset!(pixel) }.not_to raise_error
    expect { @img.color_reset!([2]) }.to raise_error(TypeError)
    expect { @img.color_reset!('x') }.to raise_error(ArgumentError)
    @img.freeze
    expect { @img.color_reset!('red') }.to raise_error(FreezeError)
  end

  def test_compare_channel
    img1 = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    img2 = Magick::Image.read(IMAGES_DIR + '/Button_1.gif').first

    Magick::MetricType.values do |metric|
      expect { img1.compare_channel(img2, metric) }.not_to raise_error
    end
    expect { img1.compare_channel(img2, 2) }.to raise_error(TypeError)
    expect { img1.compare_channel }.to raise_error(ArgumentError)

    ilist = Magick::ImageList.new
    ilist << img2
    expect { img1.compare_channel(ilist, Magick::MeanAbsoluteErrorMetric) }.not_to raise_error

    expect { img1.compare_channel(img2, Magick::MeanAbsoluteErrorMetric, Magick::RedChannel) }.not_to raise_error
    expect { img1.compare_channel(img2, Magick::MeanAbsoluteErrorMetric, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { img1.compare_channel(img2, Magick::MeanAbsoluteErrorMetric, 2) }.to raise_error(TypeError)
    expect { img1.compare_channel(img2, Magick::MeanAbsoluteErrorMetric, Magick::RedChannel, 2) }.to raise_error(TypeError)

    res = img1.compare_channel(img2, Magick::MeanAbsoluteErrorMetric)
    expect(res).to be_instance_of(Array)
    expect(res[0]).to be_instance_of(Magick::Image)
    expect(res[1]).to be_instance_of(Float)

    img2.destroy!
    expect { img1.compare_channel(img2, Magick::MeanAbsoluteErrorMetric) }.to raise_error(Magick::DestroyedImageError)
  end
end

if $PROGRAM_NAME == __FILE__
  IMAGES_DIR = '../doc/ex/images'
  FILES = Dir[IMAGES_DIR + '/Button_*.gif']
  Test::Unit::UI::Console::TestRunner.run(Image1UT)
end
