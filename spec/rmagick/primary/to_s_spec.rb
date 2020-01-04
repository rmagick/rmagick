describe Magick::Primary, '#to_s' do
  it 'works' do
    chrom = Magick::Image.new(10, 10).chromaticity
    red_primary = chrom.red_primary
    expect(red_primary.to_s).to match(/^x=.+, y=.+, z=.+$/)
  end
end
