RSpec.describe Magick::Image, "#adaptive_blur" do
  before do
    @img = described_class.new(20, 20)
  end

  it "works" do
    expect do
      res = @img.adaptive_blur
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error
    expect { @img.adaptive_blur(2) }.not_to raise_error
    expect { @img.adaptive_blur(3, 2) }.not_to raise_error
    expect { @img.adaptive_blur(3, 2, 2) }.to raise_error(ArgumentError)
  end
end
