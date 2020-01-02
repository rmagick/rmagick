RSpec.describe Magick::Image, "#capture" do
  before do
    @img = Magick::Image.new(20, 20)
  end

  it "works" do
    expect { Magick::Image.capture(true, true, true, true, true, true) }.to raise_error(ArgumentError)
  end
end
