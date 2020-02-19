describe Magick::TypeMetric, '#to_s' do
  it 'works' do
    draw = Magick::Draw.new
    metric = draw.get_type_metrics('ABCDEF')
    expect(metric.to_s).to eq("pixels_per_em=(x=12,y=12) ascent=9 descent=-3 width=49.7969 height=15 max_advance=13 bounds.x1=0.203125 bounds.y1=0 bounds.x2=8.125 bounds.y2=9 underline_position=-2.35938 underline_thickness=-2.35938")
  end
end
