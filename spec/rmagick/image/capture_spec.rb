RSpec.describe Magick::Image, "#capture" do
  it "works" do
    expect { described_class.capture(true, true, true, true, true, true) }.to raise_error(ArgumentError)
  end
end
