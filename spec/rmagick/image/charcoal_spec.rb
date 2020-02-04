RSpec.describe Magick::Image, "#charcoal" do
  before do
    @img = Magick::Image.new(20, 20)
  end

  it "works" do
    expect do
      res = @img.charcoal
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.charcoal(1.0) }.not_to raise_error
    expect { @img.charcoal(1.0, 2.0) }.not_to raise_error
    expect { @img.charcoal(1.0, 2.0, 3.0) }.to raise_error(ArgumentError)
  end

  it "applies a charcoal effect", supported_after('6.8.0') do
    pixels = [45, 98, 156, 209, 171, 11, 239, 236, 2, 8, 65, 247]
    image = described_class.new(2, 2)
    image.import_pixels(0, 0, 2, 2, "RGB", pixels)
    new_image = image.charcoal
    new_pixels = new_image.export_pixels(0, 0, 2, 2, "RGB")
    expect(new_pixels).to eq [53736, 53736, 53736, 48703, 48703, 48703, 9953, 9953, 9953, 51857, 51857, 51857]
  end
end
