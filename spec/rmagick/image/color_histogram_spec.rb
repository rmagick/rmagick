RSpec.describe Magick::Image, "#color_histogram" do
  before do
    @img = Magick::Image.new(20, 20)
  end

  it "works" do
    expect do
      res = @img.color_histogram
      expect(res).to be_instance_of(Hash)
    end.not_to raise_error
    expect do
      @img.class_type = Magick::PseudoClass
      res = @img.color_histogram
      expect(@img.class_type).to eq(Magick::PseudoClass)
      expect(res).to be_instance_of(Hash)
    end.not_to raise_error
  end
end
