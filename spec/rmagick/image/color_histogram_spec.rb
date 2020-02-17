RSpec.describe Magick::Image, "#color_histogram" do
  it "works" do
    image = described_class.new(20, 20)

    res = image.color_histogram
    expect(res).to be_instance_of(Hash)

    image.class_type = Magick::PseudoClass
    res = image.color_histogram
    expect(image.class_type).to eq(Magick::PseudoClass)
    expect(res).to be_instance_of(Hash)
  end
end
