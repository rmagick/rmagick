describe Magick::TypeMetric, '#to_s' do
  it 'works' do
    draw = Magick::Draw.new
    metric = draw.get_type_metrics('ABCDEF')
    expect(metric.to_s).to match(/^pixels_per_em=\(x=.+,y=.+\) ascent=.+ descent=.+ width=.+ height=.+ max_advance=.+ bounds.x1=.+ bounds.y1=.+ bounds.x2=.+ bounds.y2=.+ underline_position=.+ underline_thickness=.+$/)
  end
end
