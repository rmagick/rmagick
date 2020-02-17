RSpec.describe Magick::Draw, '#marshal_dump' do
  it 'marshals without an error' do
    skip 'this spec fails on some versions of ImageMagick'
    draw = described_class.new

    granite = Magick::Image.read('granite:').first
    s = granite.to_blob { self.format = 'miff' }
    granite = Magick::Image.from_blob(s).first
    blue_stroke = Magick::Image.new(20, 20) { self.background_color = 'blue' }
    s = blue_stroke.to_blob { self.format = 'miff' }
    blue_stroke = Magick::Image.from_blob(s).first

    draw.affine = Magick::AffineMatrix.new(1, 2, 3, 4, 5, 6)
    draw.decorate = Magick::LineThroughDecoration
    draw.encoding = 'AdobeCustom'
    draw.gravity = Magick::CenterGravity
    draw.fill = Magick::Pixel.from_color('red')
    draw.stroke = Magick::Pixel.from_color('blue')
    draw.stroke_width = 5
    draw.fill_pattern = granite
    draw.stroke_pattern = blue_stroke
    draw.text_antialias = true
    draw.font = 'Arial-Bold'
    draw.font_family = 'arial'
    draw.font_style = Magick::ItalicStyle
    draw.font_stretch = Magick::CondensedStretch
    draw.font_weight = Magick::BoldWeight
    draw.pointsize = 12
    draw.density = '72x72'
    draw.align = Magick::CenterAlign
    draw.undercolor = Magick::Pixel.from_color('green')
    draw.kerning = 10.5
    draw.interword_spacing = 3.75

    draw.circle(20, 25, 20, 28)
    dumped = nil
    expect { dumped = Marshal.dump(draw) }.not_to raise_error
    expect { Marshal.load(dumped) }.not_to raise_error
  end

  it 'works' do
    draw1 = described_class.new
    draw2 = draw1.dup
    draw2.affine = Magick::AffineMatrix.new(1, 2, 3, 4, 5, 6)
    draw2.decorate = Magick::LineThroughDecoration
    draw2.encoding = 'AdobeCustom'
    draw2.gravity = Magick::CenterGravity
    draw2.fill = Magick::Pixel.from_color('red')
    draw2.fill_pattern = Magick::Image.new(10, 10) { self.format = 'miff' }
    draw2.stroke = Magick::Pixel.from_color('blue')
    draw2.stroke_width = 5
    draw2.text_antialias = true
    draw2.font = 'Arial-Bold'
    draw2.font_family = 'arial'
    draw2.font_style = Magick::ItalicStyle
    draw2.font_stretch = Magick::CondensedStretch
    draw2.font_weight = Magick::BoldWeight
    draw2.pointsize = 12
    draw2.density = '72x72'
    draw2.align = Magick::CenterAlign
    draw2.undercolor = Magick::Pixel.from_color('green')
    draw2.kerning = 10.5
    draw2.interword_spacing = 3.75

    draw2.circle(20, 25, 20, 28)

    dumped = nil
    expect { dumped = draw2.marshal_dump }.not_to raise_error

    draw3 = draw1.dup
    draw3.marshal_load(dumped)
    expect(draw3.inspect).to eq(draw2.inspect)
  end
end
