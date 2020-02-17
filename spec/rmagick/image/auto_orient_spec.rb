RSpec.describe Magick::Image, "#auto_orient" do
  it "works" do
    Magick::OrientationType.values.each do |v|
      img = described_class.new(10, 10)
      img.orientation = v
      res = img.auto_orient
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(img)
    end

    img = described_class.new(20, 20)

    res = img.auto_orient!
    # When not changed, returns nil
    expect(res).to be(nil)
  end
end
