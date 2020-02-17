RSpec.describe Magick::Image, "#auto_orient" do
  it "works" do
    Magick::OrientationType.values.each do |v|
      image = described_class.new(10, 10)
      image.orientation = v
      result = image.auto_orient
      expect(result).to be_instance_of(described_class)
      expect(result).not_to be(image)
    end

    image = described_class.new(20, 20)

    result = image.auto_orient!
    # When not changed, returns nil
    expect(result).to be(nil)
  end
end
