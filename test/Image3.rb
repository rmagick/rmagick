require 'rmagick'
require 'minitest/autorun'
require 'fileutils'

class Image3_UT < Minitest::Test
  def setup
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  def test_profile!
    expect do
      res = @img.profile!('*', nil)
      expect(res).to be(@img)
    end.not_to raise_error
    expect { @img.profile!('icc', @p) }.not_to raise_error
    expect { @img.profile!('iptc', 'xxx') }.not_to raise_error
    expect { @img.profile!('icc', nil) }.not_to raise_error
    expect { @img.profile!('iptc', nil) }.not_to raise_error

    expect { @img.profile!('test', 'foobarbaz') }.to raise_error(ArgumentError)

    @img.freeze
    expect { @img.profile!('icc', 'xxx') }.to raise_error(FreezeError)
    expect { @img.profile!('*', nil) }.to raise_error(FreezeError)
  end

  def test_quantize
    expect do
      res = @img.quantize
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error

    Magick::ColorspaceType.values do |cs|
      expect { @img.quantize(256, cs) }.not_to raise_error
    end
    expect { @img.quantize(256, Magick::RGBColorspace, false) }.not_to raise_error
    expect { @img.quantize(256, Magick::RGBColorspace, true) }.not_to raise_error
    expect { @img.quantize(256, Magick::RGBColorspace, Magick::NoDitherMethod) }.not_to raise_error
    expect { @img.quantize(256, Magick::RGBColorspace, Magick::RiemersmaDitherMethod) }.not_to raise_error
    expect { @img.quantize(256, Magick::RGBColorspace, Magick::FloydSteinbergDitherMethod) }.not_to raise_error
    expect { @img.quantize(256, Magick::RGBColorspace, true, 2) }.not_to raise_error
    expect { @img.quantize(256, Magick::RGBColorspace, true, 2, true) }.not_to raise_error
    expect { @img.quantize('x') }.to raise_error(TypeError)
    expect { @img.quantize(16, 2) }.to raise_error(TypeError)
    expect { @img.quantize(16, Magick::RGBColorspace, false, 'x') }.to raise_error(TypeError)
    expect { @img.quantize(256, Magick::RGBColorspace, true, 2, true, true) }.to raise_error(ArgumentError)
  end

  def test_quantum_operator
    expect do
      res = @img.quantum_operator(Magick::AddQuantumOperator, 2)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    Magick::QuantumExpressionOperator.values do |op|
      expect { @img.quantum_operator(op, 2) }.not_to raise_error
    end
    expect { @img.quantum_operator(Magick::AddQuantumOperator, 2, Magick::RedChannel) }.not_to raise_error
    expect { @img.quantum_operator(2, 2) }.to raise_error(TypeError)
    expect { @img.quantum_operator(Magick::AddQuantumOperator, 'x') }.to raise_error(TypeError)
    expect { @img.quantum_operator(Magick::AddQuantumOperator, 2, 2) }.to raise_error(TypeError)
    expect { @img.quantum_operator(Magick::AddQuantumOperator, 2, Magick::RedChannel, 2) }.to raise_error(ArgumentError)
  end

  def test_radial_blur
    expect do
      res = @img.radial_blur(30)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
  end

  def test_radial_blur_channel
    res = nil
    expect { res = @img.radial_blur_channel(30) }.not_to raise_error
    expect(res).not_to be(nil)
    expect(res).to be_instance_of(Magick::Image)
    expect { res = @img.radial_blur_channel(30, Magick::RedChannel) }.not_to raise_error
    expect { res = @img.radial_blur_channel(30, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error

    expect { @img.radial_blur_channel }.to raise_error(ArgumentError)
    expect { @img.radial_blur_channel(30, 2) }.to raise_error(TypeError)
  end

  def test_raise
    expect do
      res = @img.raise
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.raise(4) }.not_to raise_error
    expect { @img.raise(4, 4) }.not_to raise_error
    expect { @img.raise(4, 4, false) }.not_to raise_error
    expect { @img.raise('x') }.to raise_error(TypeError)
    expect { @img.raise(2, 'x') }.to raise_error(TypeError)
    expect { @img.raise(4, 4, false, 2) }.to raise_error(ArgumentError)
  end

  def test_random_threshold_channel
    expect do
      res = @img.random_threshold_channel('20%')
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    threshold = Magick::Geometry.new(20)
    expect { @img.random_threshold_channel(threshold) }.not_to raise_error
    expect { @img.random_threshold_channel(threshold, Magick::RedChannel) }.not_to raise_error
    expect { @img.random_threshold_channel(threshold, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.random_threshold_channel }.to raise_error(ArgumentError)
    expect { @img.random_threshold_channel('20%', 2) }.to raise_error(TypeError)
  end

  def test_recolor
    expect { @img.recolor([1, 1, 2, 1]) }.not_to raise_error
    expect { @img.recolor('x') }.to raise_error(TypeError)
    expect { @img.recolor([1, 1, 'x', 1]) }.to raise_error(TypeError)
  end

  def test_reduce_noise
    expect do
      res = @img.reduce_noise(0)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.reduce_noise(4) }.not_to raise_error
  end

  def test_remap
    remap_image = Magick::Image.new(20, 20) { self.background_color = 'green' }
    expect { @img.remap(remap_image) }.not_to raise_error
    expect { @img.remap(remap_image, Magick::NoDitherMethod) }.not_to raise_error
    expect { @img.remap(remap_image, Magick::RiemersmaDitherMethod) }.not_to raise_error
    expect { @img.remap(remap_image, Magick::FloydSteinbergDitherMethod) }.not_to raise_error

    expect { @img.remap }.to raise_error(ArgumentError)
    expect { @img.remap(remap_image, Magick::NoDitherMethod, 1) }.to raise_error(ArgumentError)
    expect { @img.remap(remap_image, 1) }.to raise_error(TypeError)
  end

  def test_resample
    @img.x_resolution = 72
    @img.y_resolution = 72
    expect { @img.resample }.not_to raise_error
    expect { @img.resample(100) }.not_to raise_error
    expect { @img.resample(100, 100) }.not_to raise_error

    @img.x_resolution = 0
    @img.y_resolution = 0
    expect { @img.resample }.not_to raise_error
    expect { @img.resample(100) }.not_to raise_error
    expect { @img.resample(100, 100) }.not_to raise_error

    girl = Magick::Image.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    expect(girl.x_resolution).to eq(240.0)
    expect(girl.y_resolution).to eq(240.0)
    res = girl.resample(120, 120)
    expect(res.columns).to eq(100)
    expect(res.rows).to eq(125)
    expect(res.x_resolution).to eq(120.0)
    expect(res.y_resolution).to eq(120.0)
    expect(girl.columns).to eq(200)
    expect(girl.rows).to eq(250)
    expect(girl.x_resolution).to eq(240.0)
    expect(girl.y_resolution).to eq(240.0)

    Magick::FilterType.values do |filter|
      expect { @img.resample(50, 50, filter) }.not_to raise_error
    end
    expect { @img.resample(50, 50, Magick::PointFilter, 2.0) }.not_to raise_error

    expect { @img.resample('x') }.to raise_error(TypeError)
    expect { @img.resample(100, 'x') }.to raise_error(TypeError)
    expect { @img.resample(50, 50, 2) }.to raise_error(TypeError)
    expect { @img.resample(50, 50, Magick::CubicFilter, 'x') }.to raise_error(TypeError)
    expect { @img.resample(50, 50, Magick::SincFilter, 2.0, 'x') }.to raise_error(ArgumentError)
    expect { @img.resample(-100) }.to raise_error(ArgumentError)
    expect { @img.resample(100, -100) }.to raise_error(ArgumentError)
  end

  def test_resample!
    expect do
      res = @img.resample!(50)
      expect(res).to be(@img)
    end.not_to raise_error
    @img.freeze
    expect { @img.resample!(50) }.to raise_error(FreezeError)
  end

  def test_resize
    expect do
      res = @img.resize(2)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.resize(50, 50) }.not_to raise_error

    Magick::FilterType.values do |filter|
      expect { @img.resize(50, 50, filter) }.not_to raise_error
    end
    expect { @img.resize(50, 50, Magick::PointFilter, 2.0) }.not_to raise_error
    expect { @img.resize('x') }.to raise_error(TypeError)
    expect { @img.resize(50, 'x') }.to raise_error(TypeError)
    expect { @img.resize(50, 50, 2) }.to raise_error(TypeError)
    expect { @img.resize(50, 50, Magick::CubicFilter, 'x') }.to raise_error(TypeError)
    expect { @img.resize(-1.0) }.to raise_error(ArgumentError)
    expect { @img.resize(0, 50) }.to raise_error(ArgumentError)
    expect { @img.resize(50, 0) }.to raise_error(ArgumentError)
    expect { @img.resize(50, 50, Magick::SincFilter, 2.0, 'x') }.to raise_error(ArgumentError)
    expect { @img.resize }.to raise_error(ArgumentError)
  end

  def test_resize!
    expect do
      res = @img.resize!(2)
      expect(res).to be(@img)
    end.not_to raise_error
    @img.freeze
    expect { @img.resize!(0.50) }.to raise_error(FreezeError)
  end

  def test_resize_to_fill_0
    changed = @img.resize_to_fill(@img.columns, @img.rows)
    expect(changed.columns).to eq(@img.columns)
    expect(changed.rows).to eq(@img.rows)
    expect(@img).not_to be(changed)
  end

  def test_resize_to_fill_1
    @img = Magick::Image.new(200, 250)
    @img.resize_to_fill!(100, 100)
    expect(@img.columns).to eq(100)
    expect(@img.rows).to eq(100)
  end

  def test_resize_to_fill_2
    @img = Magick::Image.new(200, 250)
    changed = @img.resize_to_fill(300, 100)
    expect(changed.columns).to eq(300)
    expect(changed.rows).to eq(100)
  end

  def test_resize_to_fill_3
    @img = Magick::Image.new(200, 250)
    changed = @img.resize_to_fill(100, 300)
    expect(changed.columns).to eq(100)
    expect(changed.rows).to eq(300)
  end

  def test_resize_to_fill_4
    @img = Magick::Image.new(200, 250)
    changed = @img.resize_to_fill(300, 350)
    expect(changed.columns).to eq(300)
    expect(changed.rows).to eq(350)
  end

  def test_resize_to_fill_5
    changed = @img.resize_to_fill(20, 400)
    expect(changed.columns).to eq(20)
    expect(changed.rows).to eq(400)
  end

  def test_resize_to_fill_6
    changed = @img.resize_to_fill(3000, 400)
    expect(changed.columns).to eq(3000)
    expect(changed.rows).to eq(400)
  end

  # Make sure the old name is still around
  def test_resize_to_fill_7
    expect(@img).to respond_to(:crop_resized)
    expect(@img).to respond_to(:crop_resized!)
  end

  # 2nd argument defaults to the same value as the 1st argument
  def test_resize_to_fill_8
    changed = @img.resize_to_fill(100)
    expect(changed.columns).to eq(100)
    expect(changed.rows).to eq(100)
  end

  def test_resize_to_fit
    img = Magick::Image.new(200, 250)
    res = nil
    expect { res = img.resize_to_fit(50, 50) }.not_to raise_error
    expect(res).not_to be(nil)
    expect(res).to be_instance_of(Magick::Image)
    expect(res).not_to be(img)
    expect(res.columns).to eq(40)
    expect(res.rows).to eq(50)
  end

  def test_resize_to_fit2
    img = Magick::Image.new(200, 300)
    changed = img.resize_to_fit(100)
    expect(changed).to be_instance_of(Magick::Image)
    expect(changed).not_to be(img)
    expect(changed.columns).to eq(67)
    expect(changed.rows).to eq(100)
  end

  def test_resize_to_fit3
    img = Magick::Image.new(200, 300)
    img.resize_to_fit!(100)
    expect(img).to be_instance_of(Magick::Image)
    expect(img.columns).to eq(67)
    expect(img.rows).to eq(100)
  end

  def test_roll
    expect do
      res = @img.roll(5, 5)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
  end

  def test_rotate
    expect do
      res = @img.rotate(45)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.rotate(-45) }.not_to raise_error

    img = Magick::Image.new(100, 50)
    expect do
      res = img.rotate(90, '>')
      expect(res).to be_instance_of(Magick::Image)
      expect(res.columns).to eq(50)
      expect(res.rows).to eq(100)
    end.not_to raise_error
    expect do
      res = img.rotate(90, '<')
      expect(res).to be(nil)
    end.not_to raise_error
    expect { img.rotate(90, 't') }.to raise_error(ArgumentError)
    expect { img.rotate(90, []) }.to raise_error(TypeError)
  end

  def test_rotate!
    expect do
      res = @img.rotate!(45)
      expect(res).to be(@img)
    end.not_to raise_error
    @img.freeze
    expect { @img.rotate!(45) }.to raise_error(FreezeError)
  end

  def test_sample
    expect do
      res = @img.sample(10, 10)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.sample(2) }.not_to raise_error
    expect { @img.sample }.to raise_error(ArgumentError)
    expect { @img.sample(0) }.to raise_error(ArgumentError)
    expect { @img.sample(0, 25) }.to raise_error(ArgumentError)
    expect { @img.sample(25, 0) }.to raise_error(ArgumentError)
    expect { @img.sample(25, 25, 25) }.to raise_error(ArgumentError)
    expect { @img.sample('x') }.to raise_error(TypeError)
    expect { @img.sample(10, 'x') }.to raise_error(TypeError)
  end

  def test_sample!
    expect do
      res = @img.sample!(2)
      expect(res).to be(@img)
    end.not_to raise_error
    @img.freeze
    expect { @img.sample!(0.50) }.to raise_error(FreezeError)
  end

  def test_scale
    expect do
      res = @img.scale(10, 10)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.scale(2) }.not_to raise_error
    expect { @img.scale }.to raise_error(ArgumentError)
    expect { @img.scale(25, 25, 25) }.to raise_error(ArgumentError)
    expect { @img.scale('x') }.to raise_error(TypeError)
    expect { @img.scale(10, 'x') }.to raise_error(TypeError)
  end

  def test_scale!
    expect do
      res = @img.scale!(2)
      expect(res).to be(@img)
    end.not_to raise_error
    @img.freeze
    expect { @img.scale!(0.50) }.to raise_error(FreezeError)
  end

  def test_segment
    expect do
      res = @img.segment
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error

    # Don't test colorspaces that require PsuedoColor images
    (Magick::ColorspaceType.values - [Magick::OHTAColorspace,
                                      Magick::LabColorspace,
                                      Magick::XYZColorspace,
                                      Magick::YCbCrColorspace,
                                      Magick::YCCColorspace,
                                      Magick::YIQColorspace,
                                      Magick::YPbPrColorspace,
                                      Magick::YUVColorspace,
                                      Magick::Rec601YCbCrColorspace,
                                      Magick::Rec709YCbCrColorspace,
                                      Magick::LogColorspace]).each do |cs|
      expect { @img.segment(cs) }.not_to raise_error
    end

    expect { @img.segment(Magick::RGBColorspace, 2.0) }.not_to raise_error
    expect { @img.segment(Magick::RGBColorspace, 2.0, 2.0) }.not_to raise_error
    expect { @img.segment(Magick::RGBColorspace, 2.0, 2.0, false) }.not_to raise_error

    expect { @img.segment(Magick::RGBColorspace, 2.0, 2.0, false, 2) }.to raise_error(ArgumentError)
    expect { @img.segment(2) }.to raise_error(TypeError)
    expect { @img.segment(Magick::RGBColorspace, 'x') }.to raise_error(TypeError)
    expect { @img.segment(Magick::RGBColorspace, 2.0, 'x') }.to raise_error(TypeError)
  end

  def test_selective_blur_channel
    res = nil
    expect { res = @img.selective_blur_channel(0, 1, '10%') }.not_to raise_error
    expect(res).to be_instance_of(Magick::Image)
    expect(res).not_to be(@img)
    expect([res.columns, res.rows]).to eq([@img.columns, @img.rows])

    expect { @img.selective_blur_channel(0, 1, 0.1) }.not_to raise_error
    expect { @img.selective_blur_channel(0, 1, '10%', Magick::RedChannel) }.not_to raise_error
    expect { @img.selective_blur_channel(0, 1, '10%', Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.selective_blur_channel(0, 1, '10%', Magick::RedChannel, Magick::BlueChannel, Magick::GreenChannel) }.not_to raise_error

    expect { @img.selective_blur_channel(0, 1) }.to raise_error(ArgumentError)
    expect { @img.selective_blur_channel(0, 1, 0.1, '10%') }.to raise_error(TypeError)
  end

  def test_separate
    expect(@img.separate).to be_instance_of(Magick::ImageList)
    expect(@img.separate(Magick::BlueChannel)).to be_instance_of(Magick::ImageList)
    expect { @img.separate('x') }.to raise_error(TypeError)
  end

  def test_sepiatone
    expect do
      res = @img.sepiatone
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.sepiatone(Magick::QuantumRange * 0.80) }.not_to raise_error
    expect { @img.sepiatone(Magick::QuantumRange, 2) }.to raise_error(ArgumentError)
    expect { @img.sepiatone('x') }.to raise_error(TypeError)
  end

  def test_set_channel_depth
    Magick::ChannelType.values do |ch|
      expect { @img.set_channel_depth(ch, 8) }.not_to raise_error
    end
  end

  def test_shade
    expect do
      res = @img.shade
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.shade(true) }.not_to raise_error
    expect { @img.shade(true, 30) }.not_to raise_error
    expect { @img.shade(true, 30, 30) }.not_to raise_error
    expect { @img.shade(true, 30, 30, 2) }.to raise_error(ArgumentError)
    expect { @img.shade(true, 'x') }.to raise_error(TypeError)
    expect { @img.shade(true, 30, 'x') }.to raise_error(TypeError)
  end

  def test_shadow
    expect do
      res = @img.shadow
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.shadow(5) }.not_to raise_error
    expect { @img.shadow(5, 5) }.not_to raise_error
    expect { @img.shadow(5, 5, 3.0) }.not_to raise_error
    expect { @img.shadow(5, 5, 3.0, 0.50) }.not_to raise_error
    expect { @img.shadow(5, 5, 3.0, '50%') }.not_to raise_error
    expect { @img.shadow(5, 5, 3.0, 0.50, 2) }.to raise_error(ArgumentError)
    expect { @img.shadow('x') }.to raise_error(TypeError)
    expect { @img.shadow(5, 'x') }.to raise_error(TypeError)
    expect { @img.shadow(5, 5, 'x') }.to raise_error(TypeError)
    expect { @img.shadow(5, 5, 3.0, 'x') }.to raise_error(ArgumentError)
  end

  def test_sharpen
    expect do
      res = @img.sharpen
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.sharpen(2.0) }.not_to raise_error
    expect { @img.sharpen(2.0, 1.0) }.not_to raise_error
    expect { @img.sharpen(2.0, 1.0, 2) }.to raise_error(ArgumentError)
    expect { @img.sharpen('x') }.to raise_error(TypeError)
    expect { @img.sharpen(2.0, 'x') }.to raise_error(TypeError)
  end

  def test_sharpen_channel
    expect do
      res = @img.sharpen_channel
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.sharpen_channel(2.0) }.not_to raise_error
    expect { @img.sharpen_channel(2.0, 1.0) }.not_to raise_error
    expect { @img.sharpen_channel(2.0, 1.0, Magick::RedChannel) }.not_to raise_error
    expect { @img.sharpen_channel(2.0, 1.0, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.sharpen_channel(2.0, 1.0, Magick::RedChannel, 2) }.to raise_error(TypeError)
    expect { @img.sharpen_channel('x') }.to raise_error(TypeError)
    expect { @img.sharpen_channel(2.0, 'x') }.to raise_error(TypeError)
  end

  def test_shave
    expect do
      res = @img.shave(5, 5)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect do
      res = @img.shave!(5, 5)
      expect(res).to be(@img)
    end.not_to raise_error
    @img.freeze
    expect { @img.shave!(2, 2) }.to raise_error(FreezeError)
  end

  def test_shear
    expect do
      res = @img.shear(30, 30)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
  end

  def test_sigmoidal_contrast_channel
    expect do
      res = @img.sigmoidal_contrast_channel
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.sigmoidal_contrast_channel(3.0) }.not_to raise_error
    expect { @img.sigmoidal_contrast_channel(3.0, 50.0) }.not_to raise_error
    expect { @img.sigmoidal_contrast_channel(3.0, 50.0, true) }.not_to raise_error
    expect { @img.sigmoidal_contrast_channel(3.0, 50.0, true, Magick::RedChannel) }.not_to raise_error
    expect { @img.sigmoidal_contrast_channel(3.0, 50.0, true, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.sigmoidal_contrast_channel(3.0, 50.0, true, Magick::RedChannel, 2) }.to raise_error(TypeError)
    expect { @img.sigmoidal_contrast_channel('x') }.to raise_error(TypeError)
    expect { @img.sigmoidal_contrast_channel(3.0, 'x') }.to raise_error(TypeError)
  end

  def test_signature
    expect do
      res = @img.signature
      expect(res).to be_instance_of(String)
    end.not_to raise_error
  end

  def test_sketch
    expect { @img.sketch }.not_to raise_error
    expect { @img.sketch(0) }.not_to raise_error
    expect { @img.sketch(0, 1) }.not_to raise_error
    expect { @img.sketch(0, 1, 0) }.not_to raise_error
    expect { @img.sketch(0, 1, 0, 1) }.to raise_error(ArgumentError)
    expect { @img.sketch('x') }.to raise_error(TypeError)
    expect { @img.sketch(0, 'x') }.to raise_error(TypeError)
    expect { @img.sketch(0, 1, 'x') }.to raise_error(TypeError)
  end

  def test_solarize
    expect do
      res = @img.solarize
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.solarize(100) }.not_to raise_error
    expect { @img.solarize(-100) }.to raise_error(ArgumentError)
    expect { @img.solarize(Magick::QuantumRange + 1) }.to raise_error(ArgumentError)
    expect { @img.solarize(100, 2) }.to raise_error(ArgumentError)
    expect { @img.solarize('x') }.to raise_error(TypeError)
  end

  def test_sparse_color
    img = Magick::Image.new(100, 100)
    args = [30, 10, 'red', 10, 80, 'blue', 70, 60, 'lime', 80, 20, 'yellow']
    # ensure good calls work
    Magick::SparseColorMethod.values do |v|
      next if v == Magick::UndefinedColorInterpolate

      expect { img.sparse_color(v, *args) }.not_to raise_error
    end
    args << Magick::RedChannel
    expect { img.sparse_color(Magick::VoronoiColorInterpolate, *args) }.not_to raise_error
    args << Magick::GreenChannel
    expect { img.sparse_color(Magick::VoronoiColorInterpolate, *args) }.not_to raise_error
    args << Magick::BlueChannel
    expect { img.sparse_color(Magick::VoronoiColorInterpolate, *args) }.not_to raise_error

    # bad calls
    args = [30, 10, 'red', 10, 80, 'blue', 70, 60, 'lime', 80, 20, 'yellow']
    # invalid method
    expect { img.sparse_color(1, *args) }.to raise_error(TypeError)
    # missing arguments
    expect { img.sparse_color(Magick::VoronoiColorInterpolate) }.to raise_error(ArgumentError)
    args << 10 # too many arguments
    expect { img.sparse_color(Magick::VoronoiColorInterpolate, *args) }.to raise_error(ArgumentError)
    args.shift
    args.shift # too few
    expect { img.sparse_color(Magick::VoronoiColorInterpolate, *args) }.to raise_error(ArgumentError)

    args = [30, 10, 'red', 10, 80, 'blue', 70, 60, 'lime', 80, '20', 'yellow']
    expect { img.sparse_color(Magick::VoronoiColorInterpolate, *args) }.to raise_error(TypeError)
  end

  def test_splice
    expect do
      res = @img.splice(0, 0, 2, 2)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.splice(0, 0, 2, 2, 'red') }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { @img.splice(0, 0, 2, 2, red) }.not_to raise_error
    expect { @img.splice(0, 0, 2, 2, red, 'x') }.to raise_error(ArgumentError)
    expect { @img.splice([], 0, 2, 2, red) }.to raise_error(TypeError)
    expect { @img.splice(0, 'x', 2, 2, red) }.to raise_error(TypeError)
    expect { @img.splice(0, 0, 'x', 2, red) }.to raise_error(TypeError)
    expect { @img.splice(0, 0, 2, [], red) }.to raise_error(TypeError)
    expect { @img.splice(0, 0, 2, 2, /m/) }.to raise_error(TypeError)
  end

  def test_spread
    expect do
      res = @img.spread
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.spread(3.0) }.not_to raise_error
    expect { @img.spread(3.0, 2) }.to raise_error(ArgumentError)
    expect { @img.spread('x') }.to raise_error(TypeError)
  end

  def test_stegano
    @img = Magick::Image.new(100, 100) { self.background_color = 'black' }
    watermark = Magick::Image.new(10, 10) { self.background_color = 'white' }
    expect do
      res = @img.stegano(watermark, 0)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error

    watermark.destroy!
    expect { @img.stegano(watermark, 0) }.to raise_error(Magick::DestroyedImageError)
  end

  def test_stereo
    expect do
      res = @img.stereo(@img)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error

    img = Magick::Image.new(20, 20)
    img.destroy!
    expect { @img.stereo(img) }.to raise_error(Magick::DestroyedImageError)
  end

  def test_store_pixels
    pixels = @img.get_pixels(0, 0, @img.columns, 1)
    expect do
      res = @img.store_pixels(0, 0, @img.columns, 1, pixels)
      expect(res).to be(@img)
    end.not_to raise_error

    pixels[0] = 'x'
    expect { @img.store_pixels(0, 0, @img.columns, 1, pixels) }.to raise_error(TypeError)
    expect { @img.store_pixels(-1, 0, @img.columns, 1, pixels) }.to raise_error(RangeError)
    expect { @img.store_pixels(0, -1, @img.columns, 1, pixels) }.to raise_error(RangeError)
    expect { @img.store_pixels(0, 0, 1 + @img.columns, 1, pixels) }.to raise_error(RangeError)
    expect { @img.store_pixels(-1, 0, 1, 1 + @img.rows, pixels) }.to raise_error(RangeError)
    expect { @img.store_pixels(0, 0, @img.columns, 1, ['x']) }.to raise_error(IndexError)
  end

  def test_strip!
    expect do
      res = @img.strip!
      expect(res).to be(@img)
    end.not_to raise_error
  end

  def test_swirl
    expect do
      res = @img.swirl(30)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
  end

  def test_texture_fill_to_border
    texture = Magick::Image.read('granite:').first
    expect do
      res = @img.texture_fill_to_border(@img.columns / 2, @img.rows / 2, texture)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.texture_fill_to_border(@img.columns / 2, @img.rows / 2, 'x') }.to raise_error(NoMethodError)
    expect { @img.texture_fill_to_border(@img.columns * 2, @img.rows, texture) }.to raise_error(ArgumentError)
    expect { @img.texture_fill_to_border(@img.columns, @img.rows * 2, texture) }.to raise_error(ArgumentError)

    Magick::PaintMethod.values do |method|
      next if [Magick::FillToBorderMethod, Magick::FloodfillMethod].include?(method)

      expect { @img.texture_flood_fill('blue', texture, @img.columns, @img.rows, method) }.to raise_error(ArgumentError)
    end
  end

  def test_texture_floodfill
    texture = Magick::Image.read('granite:').first
    expect do
      res = @img.texture_floodfill(@img.columns / 2, @img.rows / 2, texture)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.texture_floodfill(@img.columns / 2, @img.rows / 2, 'x') }.to raise_error(NoMethodError)
    texture.destroy!
    expect { @img.texture_floodfill(@img.columns / 2, @img.rows / 2, texture) }.to raise_error(Magick::DestroyedImageError)
  end

  def test_threshold
    expect do
      res = @img.threshold(100)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
  end

  def test_thumbnail
    expect do
      res = @img.thumbnail(10, 10)
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.thumbnail(2) }.not_to raise_error
    expect { @img.thumbnail }.to raise_error(ArgumentError)
    expect { @img.thumbnail(-1.0) }.to raise_error(ArgumentError)
    expect { @img.thumbnail(0, 25) }.to raise_error(ArgumentError)
    expect { @img.thumbnail(25, 0) }.to raise_error(ArgumentError)
    expect { @img.thumbnail(25, 25, 25) }.to raise_error(ArgumentError)
    expect { @img.thumbnail('x') }.to raise_error(TypeError)
    expect { @img.thumbnail(10, 'x') }.to raise_error(TypeError)

    girl = Magick::Image.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    new_img = girl.thumbnail(200, 200)
    expect(new_img.columns).to eq(160)
    expect(new_img.rows).to eq(200)

    new_img = girl.thumbnail(2)
    expect(new_img.columns).to eq(400)
    expect(new_img.rows).to eq(500)
  end

  def test_thumbnail!
    expect do
      res = @img.thumbnail!(2)
      expect(res).to be(@img)
    end.not_to raise_error
    @img.freeze
    expect { @img.thumbnail!(0.50) }.to raise_error(FreezeError)
  end

  def test_tint
    expect do
      pixels = @img.get_pixels(0, 0, 1, 1)
      @img.tint(pixels[0], 1.0)
    end.not_to raise_error
    expect { @img.tint('red', 1.0) }.not_to raise_error
    expect { @img.tint('red', 1.0, 1.0) }.not_to raise_error
    expect { @img.tint('red', 1.0, 1.0, 1.0) }.not_to raise_error
    expect { @img.tint('red', 1.0, 1.0, 1.0, 1.0) }.not_to raise_error
    expect { @img.tint }.to raise_error(ArgumentError)
    expect { @img.tint('red') }.to raise_error(ArgumentError)
    expect { @img.tint('red', 1.0, 1.0, 1.0, 1.0, 1.0) }.to raise_error(ArgumentError)
    expect { @img.tint('x', 1.0) }.to raise_error(ArgumentError)
    expect { @img.tint('red', -1.0, 1.0, 1.0, 1.0) }.to raise_error(ArgumentError)
    expect { @img.tint('red', 1.0, -1.0, 1.0, 1.0) }.to raise_error(ArgumentError)
    expect { @img.tint('red', 1.0, 1.0, -1.0, 1.0) }.to raise_error(ArgumentError)
    expect { @img.tint('red', 1.0, 1.0, 1.0, -1.0) }.to raise_error(ArgumentError)
    expect { @img.tint(1.0, 1.0) }.to raise_error(TypeError)
    expect { @img.tint('red', 'green') }.to raise_error(TypeError)
    expect { @img.tint('red', 1.0, 'green') }.to raise_error(TypeError)
    expect { @img.tint('red', 1.0, 1.0, 'green') }.to raise_error(TypeError)
    expect { @img.tint('red', 1.0, 1.0, 1.0, 'green') }.to raise_error(TypeError)
  end

  def test_to_blob
    res = nil
    expect { res = @img.to_blob { self.format = 'miff' } }.not_to raise_error
    expect(res).to be_instance_of(String)
    restored = Magick::Image.from_blob(res)
    expect(restored[0]).to eq(@img)
  end

  def test_to_color
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect do
      res = @img.to_color(red)
      expect(res).to eq('red')
    end.not_to raise_error
  end

  def test_transparent
    expect do
      res = @img.transparent('white')
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    pixel = Magick::Pixel.new
    expect { @img.transparent(pixel) }.not_to raise_error
    expect { @img.transparent('white', Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { @img.transparent('white', alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { @img.transparent('white', wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { @img.transparent('white', alpha: Magick::TransparentAlpha, extra: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { @img.transparent('white', Magick::TransparentAlpha, 2) }.to raise_error(ArgumentError)
    expect { @img.transparent('white', Magick::QuantumRange / 2) }.to raise_error(ArgumentError)
    expect { @img.transparent(2) }.to raise_error(TypeError)
  end

  def test_transparent_chroma
    expect(@img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange))).to be_instance_of(Magick::Image)
    expect { @img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange)) }.not_to raise_error
    expect { @img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { @img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { @img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { @img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), Magick::TransparentAlpha, true) }.to raise_error(ArgumentError)
    expect { @img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), true, alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { @img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), false, wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { @img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), false, alpha: Magick::TransparentAlpha, extra: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
  end

  def test_transpose
    expect do
      res = @img.transpose
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect do
      res = @img.transpose!
      expect(res).to be_instance_of(Magick::Image)
      expect(res).to be(@img)
    end.not_to raise_error
  end

  def test_transverse
    expect do
      res = @img.transverse
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect do
      res = @img.transverse!
      expect(res).to be_instance_of(Magick::Image)
      expect(res).to be(@img)
    end.not_to raise_error
  end

  def test_trim
    # Can't use the default image because it's a solid color
    hat = Magick::Image.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    expect do
      expect(hat.trim).to be_instance_of(Magick::Image)
      expect(hat.trim(10)).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { hat.trim(10, 10) }.to raise_error(ArgumentError)

    expect do
      res = hat.trim!
      expect(res).to be(hat)

      res = hat.trim!(10)
      expect(res).to be(hat)
    end.not_to raise_error
    expect { hat.trim!(10, 10) }.to raise_error(ArgumentError)
  end

  def test_unique_colors
    expect do
      res = @img.unique_colors
      expect(res).to be_instance_of(Magick::Image)
      expect(res.columns).to eq(1)
      expect(res.rows).to eq(1)
    end.not_to raise_error
  end

  def test_unsharp_mask
    expect do
      res = @img.unsharp_mask
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error

    expect { @img.unsharp_mask(2.0) }.not_to raise_error
    expect { @img.unsharp_mask(2.0, 1.0) }.not_to raise_error
    expect { @img.unsharp_mask(2.0, 1.0, 0.50) }.not_to raise_error
    expect { @img.unsharp_mask(2.0, 1.0, 0.50, 0.10) }.not_to raise_error
    expect { @img.unsharp_mask(2.0, 1.0, 0.50, 0.10, 2) }.to raise_error(ArgumentError)
    expect { @img.unsharp_mask(-2.0, 1.0, 0.50, 0.10) }.to raise_error(ArgumentError)
    expect { @img.unsharp_mask(2.0, 0.0, 0.50, 0.10) }.to raise_error(ArgumentError)
    expect { @img.unsharp_mask(2.0, 1.0, 0.0, 0.10) }.to raise_error(ArgumentError)
    expect { @img.unsharp_mask(2.0, 1.0, 0.01, -0.10) }.to raise_error(ArgumentError)
    expect { @img.unsharp_mask('x') }.to raise_error(TypeError)
    expect { @img.unsharp_mask(2.0, 'x') }.to raise_error(TypeError)
    expect { @img.unsharp_mask(2.0, 1.0, 'x') }.to raise_error(TypeError)
    expect { @img.unsharp_mask(2.0, 1.0, 0.50, 'x') }.to raise_error(TypeError)
  end

  def test_unsharp_mask_channel
    expect do
      res = @img.unsharp_mask_channel
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error

    expect { @img.unsharp_mask_channel(2.0) }.not_to raise_error
    expect { @img.unsharp_mask_channel(2.0, 1.0) }.not_to raise_error
    expect { @img.unsharp_mask_channel(2.0, 1.0, 0.50) }.not_to raise_error
    expect { @img.unsharp_mask_channel(2.0, 1.0, 0.50, 0.10) }.not_to raise_error
    expect { @img.unsharp_mask_channel(2.0, 1.0, 0.50, 0.10, Magick::RedChannel) }.not_to raise_error
    expect { @img.unsharp_mask_channel(2.0, 1.0, 0.50, 0.10, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error
    expect { @img.unsharp_mask_channel(2.0, 1.0, 0.50, 0.10, Magick::RedChannel, 2) }.to raise_error(TypeError)
    expect { @img.unsharp_mask_channel(2.0, 1.0, 0.50, 0.10, 2) }.to raise_error(TypeError)
    expect { @img.unsharp_mask_channel('x') }.to raise_error(TypeError)
    expect { @img.unsharp_mask_channel(2.0, 'x') }.to raise_error(TypeError)
    expect { @img.unsharp_mask_channel(2.0, 1.0, 'x') }.to raise_error(TypeError)
    expect { @img.unsharp_mask_channel(2.0, 1.0, 0.50, 'x') }.to raise_error(TypeError)
  end

  def test_view
    expect do
      res = @img.view(0, 0, 5, 5)
      expect(res).to be_instance_of(Magick::Image::View)
    end.not_to raise_error
    expect do
      @img.view(0, 0, 5, 5) { |v| expect(v).to be_instance_of(Magick::Image::View) }
    end.not_to raise_error
    expect { @img.view(-1, 0, 5, 5) }.to raise_error(RangeError)
    expect { @img.view(0, -1, 5, 5) }.to raise_error(RangeError)
    expect { @img.view(1, 0, @img.columns, 5) }.to raise_error(RangeError)
    expect { @img.view(0, 1, 5, @img.rows) }.to raise_error(RangeError)
    expect { @img.view(0, 0, 0, 1) }.to raise_error(ArgumentError)
    expect { @img.view(0, 0, 1, 0) }.to raise_error(ArgumentError)
  end

  def test_vignette
    expect do
      res = @img.vignette
      expect(res).to be_instance_of(Magick::Image)
      expect(@img).not_to be(res)
    end.not_to raise_error
    expect { @img.vignette(0) }.not_to raise_error
    expect { @img.vignette(0, 0) }.not_to raise_error
    expect { @img.vignette(0, 0, 0) }.not_to raise_error
    expect { @img.vignette(0, 0, 0, 1) }.not_to raise_error
    # too many arguments
    expect { @img.vignette(0, 0, 0, 1, 1) }.to raise_error(ArgumentError)
  end

  def test_watermark
    mark = Magick::Image.new(5, 5)
    mark_list = Magick::ImageList.new
    mark_list << mark.copy
    expect { @img.watermark(mark) }.not_to raise_error
    expect { @img.watermark(mark_list) }.not_to raise_error
    expect { @img.watermark(mark, 0.50) }.not_to raise_error
    expect { @img.watermark(mark, '50%') }.not_to raise_error
    expect { @img.watermark(mark, 0.50, 0.50) }.not_to raise_error
    expect { @img.watermark(mark, 0.50, '50%') }.not_to raise_error
    expect { @img.watermark(mark, 0.50, 0.50, 10) }.not_to raise_error
    expect { @img.watermark(mark, 0.50, 0.50, 10, 10) }.not_to raise_error
    expect { @img.watermark(mark, 0.50, 0.50, Magick::NorthEastGravity) }.not_to raise_error
    expect { @img.watermark(mark, 0.50, 0.50, Magick::NorthEastGravity, 10) }.not_to raise_error
    expect { @img.watermark(mark, 0.50, 0.50, Magick::NorthEastGravity, 10, 10) }.not_to raise_error

    expect { @img.watermark }.to raise_error(ArgumentError)
    expect { @img.watermark(mark, 'x') }.to raise_error(ArgumentError)
    expect { @img.watermark(mark, 0.50, 'x') }.to raise_error(ArgumentError)
    expect { @img.watermark(mark, 0.50, '1500%') }.to raise_error(ArgumentError)
    expect { @img.watermark(mark, 0.50, 0.50, 'x') }.to raise_error(TypeError)
    expect { @img.watermark(mark, 0.50, 0.50, Magick::NorthEastGravity, 'x') }.to raise_error(TypeError)
    expect { @img.watermark(mark, 0.50, 0.50, Magick::NorthEastGravity, 10, 'x') }.to raise_error(TypeError)

    mark.destroy!
    expect { @img.watermark(mark) }.to raise_error(Magick::DestroyedImageError)
  end

  def test_wave
    expect do
      res = @img.wave
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.wave(25) }.not_to raise_error
    expect { @img.wave(25, 200) }.not_to raise_error
    expect { @img.wave(25, 200, 2) }.to raise_error(ArgumentError)
    expect { @img.wave('x') }.to raise_error(TypeError)
    expect { @img.wave(25, 'x') }.to raise_error(TypeError)
  end

  def test_wet_floor
    expect(@img.wet_floor).to be_instance_of(Magick::Image)
    expect { @img.wet_floor(0.0) }.not_to raise_error
    expect { @img.wet_floor(0.5) }.not_to raise_error
    expect { @img.wet_floor(0.5, 10) }.not_to raise_error
    expect { @img.wet_floor(0.5, 0.0) }.not_to raise_error

    expect { @img.wet_floor(2.0) }.to raise_error(ArgumentError)
    expect { @img.wet_floor(-2.0) }.to raise_error(ArgumentError)
    expect { @img.wet_floor(0.5, -1.0) }.to raise_error(ArgumentError)
    expect { @img.wet_floor(0.5, 10, 0.5) }.to raise_error(ArgumentError)
  end

  def test_white_threshold
    expect { @img.white_threshold }.to raise_error(ArgumentError)
    expect { @img.white_threshold(50) }.not_to raise_error
    expect { @img.white_threshold(50, 50) }.not_to raise_error
    expect { @img.white_threshold(50, 50, 50) }.not_to raise_error
    expect { @img.white_threshold(50, 50, 50, 50) }.to raise_error(ArgumentError)
    expect { @img.white_threshold(50, 50, 50, alpha: 50) }.not_to raise_error
    expect { @img.white_threshold(50, 50, 50, wrong: 50) }.to raise_error(ArgumentError)
    expect { @img.white_threshold(50, 50, 50, alpha: 50, extra: 50) }.to raise_error(ArgumentError)
    expect { @img.white_threshold(50, 50, 50, 50, 50) }.to raise_error(ArgumentError)
    res = @img.white_threshold(50)
    expect(res).to be_instance_of(Magick::Image)
  end

  # test write with #format= attribute
  def test_write
    @img.write('temp.gif')
    img = Magick::Image.read('temp.gif')
    expect(img.first.format).to eq('GIF')
    FileUtils.rm('temp.gif')

    @img.write('jpg:temp.foo')
    img = Magick::Image.read('temp.foo')
    expect(img.first.format).to eq('JPEG')
    FileUtils.rm('temp.foo')

    @img.write('temp.0') { self.format = 'JPEG' }
    img = Magick::Image.read('temp.0')
    expect(img.first.format).to eq('JPEG')

    # JPEG has two names.
    @img.write('jpeg:temp.0') { self.format = 'JPEG' }
    img = Magick::Image.read('temp.0')
    expect(img.first.format).to eq('JPEG')

    @img.write('jpg:temp.0') { self.format = 'JPG' }
    img = Magick::Image.read('temp.0')
    expect(img.first.format).to eq('JPEG')

    @img.write('jpg:temp.0') { self.format = 'JPEG' }
    img = Magick::Image.read('temp.0')
    expect(img.first.format).to eq('JPEG')

    @img.write('jpeg:temp.0') { self.format = 'JPG' }
    img = Magick::Image.read('temp.0')
    expect(img.first.format).to eq('JPEG')

    expect do
      @img.write('gif:temp.0') { self.format = 'JPEG' }
    end.to raise_error(RuntimeError)

    f = File.new('test.0', 'w')
    @img.write(f) { self.format = 'JPEG' }
    f.close
    img = Magick::Image.read('test.0')
    expect(img.first.format).to eq('JPEG')
    FileUtils.rm('test.0')

    @img.write('test.webp')
    img = Magick::Image.read('test.webp')
    expect(img.first.format).to eq('WEBP')
    FileUtils.rm('test.webp') rescue nil # Avoid failure on AppVeyor

    f = File.new('test.0', 'w')
    Magick::Image.new(100, 100).write(f) do
      self.format = 'JPEG'
      self.colorspace = Magick::CMYKColorspace
    end
    f.close
    img = Magick::Image.read('test.0')
    expect(img.first.format).to eq('JPEG')
    FileUtils.rm('test.0')
  end
end

if $PROGRAM_NAME == __FILE__
  IMAGES_DIR = '../doc/ex/images'
  FILES = Dir[IMAGES_DIR + '/Button_*.gif']
  Test::Unit::UI::Console::TestRunner.run(Image3UT)
end
