RSpec.describe Magick::Image, "#alpha" do
  before do
    @img = described_class.new(20, 20)
  end

  it "works" do
    expect { @img.alpha }.not_to raise_error
    expect(@img.alpha).to be(false)
    expect { @img.alpha Magick::ActivateAlphaChannel }.not_to raise_error
    expect(@img.alpha).to be(true)
  end
end
