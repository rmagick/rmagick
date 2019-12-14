RSpec.describe Magick::Draw, '#marshal_dump' do
  let(:draw) { described_class.new }

  it 'marshals without an error' do
    skip 'this spec fails on some versions of ImageMagick'
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
end
