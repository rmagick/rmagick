# frozen_string_literal: true

RSpec.describe Magick::Draw do
  def converting(conversion, value, action)
    object = Object.new
    object.define_singleton_method(conversion) do
      action.call
      value
    end
    object
  end

  [
    ["affine=", :to_f, 1.0, ->(draw, arg) { draw.affine = Magick::AffineMatrix.new(arg, 0, 0, 1, 0, 0) }],
    ["density=", :to_str, "72x72", ->(draw, arg) { draw.density = arg }],
    ["encoding=", :to_str, "UTF-8", ->(draw, arg) { draw.encoding = arg }],
    ["font=", :to_str, "Helvetica", ->(draw, arg) { draw.font = arg }],
    ["font_family=", :to_str, "Helvetica", ->(draw, arg) { draw.font_family = arg }],
    ["fill=", :to_str, "red", ->(draw, arg) { draw.fill = arg }],
    ["stroke=", :to_str, "red", ->(draw, arg) { draw.stroke = arg }],
    ["undercolor=", :to_str, "red", ->(draw, arg) { draw.undercolor = arg }],
    ["fill_pattern=", :cur_image, nil, ->(draw, arg) { draw.fill_pattern = arg }],
    ["stroke_pattern=", :cur_image, nil, ->(draw, arg) { draw.stroke_pattern = arg }],
    ["kerning=", :to_f, 1.0, ->(draw, arg) { draw.kerning = arg }],
    ["interline_spacing=", :to_f, 1.0, ->(draw, arg) { draw.interline_spacing = arg }],
    ["interword_spacing=", :to_f, 1.0, ->(draw, arg) { draw.interword_spacing = arg }],
    ["pointsize=", :to_f, 12.0, ->(draw, arg) { draw.pointsize = arg }],
    ["rotation=", :to_f, 45.0, ->(draw, arg) { draw.rotation = arg }],
    ["stroke_width=", :to_f, 2.0, ->(draw, arg) { draw.stroke_width = arg }],
    ["primitive", :to_str, "point 0,0", ->(draw, arg) { draw.primitive(arg) }]
  ].each do |name, conversion, value, call|
    it "raises an error when converting the argument of ##{name} freezes the Draw" do
      draw = described_class.new
      arg = converting(conversion, value || Magick::Image.new(2, 2), -> { draw.freeze })

      expect { call.call(draw, arg) }.to raise_error(FrozenError)
    end
  end

  it "keeps the affine matrix when an element of the new one cannot be converted" do
    draw = described_class.new
    draw.affine = Magick::AffineMatrix.new(2, 0, 0, 2, 0, 0)

    expect { draw.affine = Magick::AffineMatrix.new(3, 0, 0, "x", 0, 0) }.to raise_error(TypeError)
    expect(draw.marshal_dump[:affine]).to eq(Magick::AffineMatrix.new(2, 0, 0, 2, 0, 0))
  end
end
