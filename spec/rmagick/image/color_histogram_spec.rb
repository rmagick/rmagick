RSpec.describe Magick::Image, "#color_histogram" do
  it "works" do
    img = described_class.new(20, 20)

    res = img.color_histogram
    expect(res).to be_instance_of(Hash)

    img.class_type = Magick::PseudoClass
    res = img.color_histogram
    expect(img.class_type).to eq(Magick::PseudoClass)
    expect(res).to be_instance_of(Hash)
  end
end
