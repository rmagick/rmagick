require 'rmagick'
require 'minitest/autorun'

class StructUT < Minitest::Test
  def test_chromaticity_to_s
    image = Magick::Image.new(10, 10)
    expect(image.chromaticity.to_s).to match(/red_primary=\(x=.+,y=.+\) green_primary=\(x=.+,y=.+\) blue_primary=\(x=.+,y=.+\) white_point=\(x=.+,y=.+\)/)
  end

  def test_export_color_info
    color = Magick.colors[0]
    expect(color).to be_instance_of(Magick::Color)
    expect(color.to_s).to match(/name=.+, compliance=.+, color.red=.+, color.green=.+, color.blue=.+, color.alpha=.+/)
  end

  def test_export_type_info
    font = Magick.fonts[0]
    expect(font.to_s).to match(/^name=.+, description=.+, family=.+, style=.+, stretch=.+, weight=.+, encoding=.*, foundry=.*, format=.*$/)
  end

  def test_export_point_info
    draw = Magick::Draw.new
    metric = draw.get_type_metrics('ABCDEF')
    expect(metric.to_s).to match(/^pixels_per_em=\(x=.+,y=.+\) ascent=.+ descent=.+ width=.+ height=.+ max_advance=.+ bounds.x1=.+ bounds.y1=.+ bounds.x2=.+ bounds.y2=.+ underline_position=.+ underline_thickness=.+$/)
  end

  def test_primary_info_to_s
    chrom = Magick::Image.new(10, 10).chromaticity
    red_primary = chrom.red_primary
    expect(red_primary.to_s).to match(/^x=.+, y=.+, z=.+$/)
  end

  def test_rectangle_info_to_s
    rect = Magick::Rectangle.new(10, 20, 30, 40)
    expect(rect.to_s).to eq('width=10, height=20, x=30, y=40')
  end

  def test_segment_info_to_s
    segment = Magick::Segment.new(10, 20, 30, 40)
    expect(segment.to_s).to eq('x1=10, y1=20, x2=30, y2=40')
  end
end
