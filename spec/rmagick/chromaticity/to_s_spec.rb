describe Magick::Chromaticity, '#to_s' do
  it 'works' do
    image = Magick::Image.new(10, 10)
    expect(image.chromaticity.to_s).to match(/red_primary=\(x=.+,y=.+\) green_primary=\(x=.+,y=.+\) blue_primary=\(x=.+,y=.+\) white_point=\(x=.+,y=.+\)/)
  end
end
