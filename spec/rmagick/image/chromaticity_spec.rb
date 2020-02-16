RSpec.describe Magick::Image, '#chromaticity' do
  it 'works' do
    img = described_class.new(100, 100)

    chrom = img.chromaticity
    expect { img.chromaticity }.not_to raise_error
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
    expect { img.chromaticity = chrom }.not_to raise_error
    expect { img.chromaticity = 2 }.to raise_error(TypeError)
  end
end
