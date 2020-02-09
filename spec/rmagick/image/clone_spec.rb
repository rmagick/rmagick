RSpec.describe Magick::Image, "#clone" do
  before do
    @img = described_class.new(20, 20)
  end

  it "works" do
    expect do
      res = @img.clone
      expect(res).to be_instance_of(described_class)
      expect(@img).to eq(res)
    end.not_to raise_error
    res = @img.clone
    expect(@img.frozen?).to eq(res.frozen?)
    @img.freeze
    res = @img.clone
    expect(@img.frozen?).to eq(res.frozen?)
  end
end
