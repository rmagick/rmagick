RSpec.describe Magick::Image, "#clone" do
  it "works" do
    img = described_class.new(20, 20)

    res = img.clone
    expect(res).to be_instance_of(described_class)
    expect(img).to eq(res)

    res = img.clone
    expect(img.frozen?).to eq(res.frozen?)
    img.freeze
    res = img.clone
    expect(img.frozen?).to eq(res.frozen?)
  end
end
