RSpec.describe Magick::Image, "#auto_orient" do
  it "works" do
    Magick::OrientationType.values.each do |v|
      expect do
        img = described_class.new(10, 10)
        img.orientation = v
        res = img.auto_orient
        expect(res).to be_instance_of(described_class)
        expect(res).not_to be(img)
      end.not_to raise_error
    end

    img = described_class.new(20, 20)

    expect do
      res = img.auto_orient!
      # When not changed, returns nil
      expect(res).to be(nil)
    end.not_to raise_error
  end
end
