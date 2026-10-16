# frozen_string_literal: true

RSpec.describe Magick::Image do
  def converting(conversion, value, action)
    object = Object.new
    object.define_singleton_method(conversion) do
      action.call
      value
    end
    object
  end

  def replacing(image)
    -> { image.__send__(:initialize_copy, described_class.new(8, 8)) }
  end

  [
    ['gamma=', :to_f, 1.0, ->(image, arg) { image.gamma = arg }],
    ['x_resolution=', :to_f, 72.0, ->(image, arg) { image.x_resolution = arg }],
    ['fuzz=', :to_f, 1.0, ->(image, arg) { image.fuzz = arg }],
    ['ticks_per_second=', :to_int, 10, ->(image, arg) { image.ticks_per_second = arg }],
    ['background_color=', :to_str, 'red', ->(image, arg) { image.background_color = arg }],
    ['density=', :to_str, '72x72', ->(image, arg) { image.density = arg }],
    ['geometry=', :to_str, '2x2', ->(image, arg) { image.geometry = arg }],
    ['format=', :to_str, 'PNG', ->(image, arg) { image.format = arg }],
    ['bias=', :to_f, 0.5, ->(image, arg) { image.bias = arg }],
    ['[]', :to_str, 'comment', ->(image, arg) { image[arg] }],
    ['[]=', :to_str, 'value', ->(image, arg) { image['comment'] = arg }],
    ['define', :to_str, 'value', ->(image, arg) { image.define('key', arg) }],
    ['artifact', :to_str, 'key', ->(image, arg) { image.artifact(arg) }],
    ['delete_profile', :to_str, 'icc', ->(image, arg) { image.delete_profile(arg) }],
    ['adaptive_resize', :to_f, 0.5, ->(image, arg) { image.adaptive_resize(arg) }],
    ['blur_image', :to_f, 1.0, ->(image, arg) { image.blur_image(arg) }],
    ['blur_channel', :to_f, 1.0, ->(image, arg) { image.blur_channel(arg) }],
    ['motion_blur', :to_f, 1.0, ->(image, arg) { image.motion_blur(arg) }],
    ['unsharp_mask', :to_f, 1.0, ->(image, arg) { image.unsharp_mask(arg) }],
    ['resize', :to_f, 0.5, ->(image, arg) { image.resize(arg) }],
    ['resize!', :to_f, 0.5, ->(image, arg) { image.resize!(arg) }],
    ['rotate!', :to_f, 90.0, ->(image, arg) { image.rotate!(arg) }],
    ['sample!', :to_int, 2, ->(image, arg) { image.sample!(arg, 2) }],
    ['thumbnail', :to_f, 0.5, ->(image, arg) { image.thumbnail(arg) }],
    ['resample', :to_f, 36.0, ->(image, arg) { image.resample(arg) }],
    ['crop', :to_int, 2, ->(image, arg) { image.crop(Magick::CenterGravity, arg, 2) }],
    ['crop!', :to_int, 2, ->(image, arg) { image.crop!(0, 0, arg, 2) }],
    ['excerpt', :to_int, 2, ->(image, arg) { image.excerpt(0, 0, arg, 2) }],
    ['extent', :to_int, 2, ->(image, arg) { image.extent(arg, 2) }],
    ['frame', :to_int, 2, ->(image, arg) { image.frame(arg) }],
    ['modulate', :to_f, 1.0, ->(image, arg) { image.modulate(arg) }],
    ['colorize', :to_str, 'red', ->(image, arg) { image.colorize(0.5, 0.5, 0.5, arg) }],
    ['level_colors', :to_str, 'red', ->(image, arg) { image.level_colors('black', arg) }],
    ['pixel_color', :to_int, 0, ->(image, arg) { image.pixel_color(arg, 0) }],
    ['get_pixels', :to_int, 0, ->(image, arg) { image.get_pixels(arg, 0, 1, 1) }],
    ['store_pixels', :to_int, 0, ->(image, arg) { image.store_pixels(arg, 0, 1, 1, [Magick::Pixel.new]) }],
    ['export_pixels', :to_int, 0, ->(image, arg) { image.export_pixels(arg) }],
    ['import_pixels', :to_f, 0.5, ->(image, arg) { image.import_pixels(0, 0, 1, 1, 'R', [arg]) }],
    ['import_pixels with a String', :to_str, 'a', ->(image, arg) { image.import_pixels(0, 0, 1, 1, 'R', arg) }],
    ['dispatch', :to_int, 0, ->(image, arg) { image.dispatch(arg, 0, 1, 1, 'R') }],
    ['linear_stretch', :to_f, 0.0, ->(image, arg) { image.linear_stretch(arg) }],
    ['convolve', :to_f, 1.0, ->(image, arg) { image.convolve(1, [arg]) }],
    ['convolve_channel', :to_f, 1.0, ->(image, arg) { image.convolve_channel(1, [arg], Magick::RedChannel) }],
    ['function_channel', :to_f, 1.0, ->(image, arg) { image.function_channel(Magick::PolynomialFunction, arg) }],
    ['recolor', :to_f, 1.0, ->(image, arg) { image.recolor([arg]) }],
    ['wet_floor', :to_f, 0.5, ->(image, arg) { image.wet_floor(arg) }],
    ['composite', :cur_image, nil, ->(image, arg) { image.composite(arg, Magick::CenterGravity, Magick::OverCompositeOp) }],
    ['composite_affine', :cur_image, nil, ->(image, arg) { image.composite_affine(arg, Magick::AffineMatrix.new(1, 0, 0, 1, 0, 0)) }],
    ['difference', :cur_image, nil, ->(image, arg) { image.difference(arg) }],
    ['distortion_channel', :cur_image, nil, ->(image, arg) { image.distortion_channel(arg, Magick::MeanAbsoluteErrorMetric) }],
    ['stereo', :cur_image, nil, ->(image, arg) { image.stereo(arg) }],
    ['add_compose_mask', :cur_image, nil, ->(image, arg) { image.add_compose_mask(arg) }],
    ['clut_channel', :cur_image, nil, ->(image, arg) { image.clut_channel(arg) }],
    ['remap', :cur_image, nil, ->(image, arg) { image.remap(arg) }],
    ['find_similar_region', :cur_image, nil, ->(image, arg) { image.find_similar_region(arg) }],
    ['blend', :cur_image, nil, ->(image, arg) { image.blend(arg, 0.5, 0.5, Magick::CenterGravity) }]
  ].each do |name, conversion, value, call|
    it "raises an error when converting an argument of ##{name} destroys the image" do
      image = described_class.new(4, 4)
      arg = converting(conversion, value || described_class.new(4, 4), -> { image.destroy! })

      expect { call.call(image, arg) }.to raise_error(Magick::DestroyedImageError)
    end
  end

  [
    ['composite', :to_int, 0, ->(image, other, arg) { image.composite(other, arg, 0, Magick::OverCompositeOp) }],
    ['composite_affine', :to_f, 1.0, ->(image, other, arg) { image.composite_affine(other, Magick::AffineMatrix.new(arg, 0, 0, 1, 0, 0)) }],
    ['stegano', :to_int, 0, ->(image, other, arg) { image.stegano(other, arg) }],
    ['texture_flood_fill', :to_int, 0, ->(image, other, arg) { image.texture_flood_fill('white', other, arg, 0, Magick::FloodfillMethod) }],
    ['watermark', :to_int, 0, ->(image, other, arg) { image.watermark(other, 0.5, 0.5, Magick::CenterGravity, arg, 0) }]
  ].each do |name, conversion, value, call|
    it "raises an error when converting an argument of ##{name} destroys the image argument" do
      image = described_class.new(4, 4)
      other = described_class.new(4, 4)
      arg = converting(conversion, value, -> { other.destroy! })

      expect { call.call(image, other, arg) }.to raise_error(Magick::DestroyedImageError)
    end
  end

  it 'resizes the new image when converting the argument of #resize! replaces the image' do
    image = described_class.new(4, 4)

    image.resize!(converting(:to_f, 0.5, replacing(image)))
    expect([image.columns, image.rows]).to eq([4, 4])
  end

  it 'sets the color of the new image when converting the argument of #background_color= replaces the image' do
    image = described_class.new(4, 4)

    image.background_color = converting(:to_str, 'red', replacing(image))
    expect(Magick::Pixel.from_color(image.background_color)).to eq(Magick::Pixel.from_color('red'))
  end

  it 'crops the new image when converting an argument of #crop replaces the image' do
    image = described_class.new(4, 4)

    expect(image.crop(0, 0, converting(:to_int, 6, replacing(image)), 6).columns).to eq(6)
  end
end
