RSpec.describe Magick::Image, "#capture" do
  before do
    @img = described_class.new(20, 20)
  end

  it "works" do
    expect { described_class.capture(true, true, true, true, true, true) }.to raise_error(ArgumentError)
  end
end
