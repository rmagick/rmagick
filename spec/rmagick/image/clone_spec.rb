RSpec.describe Magick::Image, "#clone" do
  it "works" do
    image = described_class.new(20, 20)

    res = image.clone
    expect(res).to be_instance_of(described_class)
    expect(image).to eq(res)

    res = image.clone
    expect(image.frozen?).to eq(res.frozen?)
    image.freeze
    res = image.clone
    expect(image.frozen?).to eq(res.frozen?)
  end
end
