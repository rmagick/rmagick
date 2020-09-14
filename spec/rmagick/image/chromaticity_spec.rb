RSpec.describe Magick::Image, '#chromaticity' do
  it 'works' do
    image = described_class.new(100, 100)

    chrom = image.chromaticity
    expect { image.chromaticity }.not_to raise_error
    expect(chrom).to be_instance_of(Magick::Chromaticity)
    expect(chrom.red_primary.x).to eq(0)
    expect(chrom.red_primary.y).to eq(0)
    expect(chrom.red_primary.z).to eq(0)
    expect(chrom.green_primary.x).to eq(0)
    expect(chrom.green_primary.y).to eq(0)
    expect(chrom.green_primary.z).to eq(0)
    expect(chrom.blue_primary.x).to eq(0)
    expect(chrom.blue_primary.y).to eq(0)
    expect(chrom.blue_primary.z).to eq(0)
    expect(chrom.white_point.x).to eq(0)
    expect(chrom.white_point.y).to eq(0)
    expect(chrom.white_point.z).to eq(0)
    expect { image.chromaticity = chrom }.not_to raise_error
    expect { image.chromaticity = 2 }.to raise_error(TypeError)
  end

  it 'still works' do
    image = described_class.new(100, 100)

    chromaticity = Magick::Chromaticity.new(
      Magick::Primary.new(0.5, 0.5, 0),
      Magick::Primary.new(0.5, 0.5, 0),
      Magick::Primary.new(0.5, 0.5, 0),
      Magick::Primary.new(0.5, 0.5, 0),
    )
    image.chromaticity = chromaticity
    expect(image.chromaticity).to eq chromaticity
  end
end
