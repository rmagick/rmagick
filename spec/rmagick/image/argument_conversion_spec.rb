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

  [
    ['gamma=', :to_f, 1.0, ->(image, arg) { image.gamma = arg }],
    ['x_resolution=', :to_f, 72.0, ->(image, arg) { image.x_resolution = arg }],
    ['fuzz=', :to_f, 1.0, ->(image, arg) { image.fuzz = arg }],
    ['ticks_per_second=', :to_int, 10, ->(image, arg) { image.ticks_per_second = arg }],
    ['background_color=', :to_str, 'red', ->(image, arg) { image.background_color = arg }],
    ['density=', :to_str, '72x72', ->(image, arg) { image.density = arg }],
    ['geometry=', :to_str, '2x2', ->(image, arg) { image.geometry = arg }],
    ['format=', :to_str, 'PNG', ->(image, arg) { image.format = arg }],
    ['bias=', :to_f, 0.5, ->(image, arg) { image.bias = arg }]
  ].each do |name, conversion, value, call|
    it "raises an error when converting an argument of ##{name} destroys the image" do
      image = described_class.new(4, 4)
      arg = converting(conversion, value, -> { image.destroy! })

      expect { call.call(image, arg) }.to raise_error(Magick::DestroyedImageError)
    end
  end
end
