RSpec.describe Magick::Image, "#clone" do
  it "works" do
    image = described_class.new(20, 20)

    result = image.clone
    expect(result).to be_instance_of(described_class)
    expect(image).to eq(result)

    result = image.clone
    expect(image.frozen?).to eq(result.frozen?)
    image.freeze
    result = image.clone
    expect(image.frozen?).to eq(result.frozen?)
  end
end
