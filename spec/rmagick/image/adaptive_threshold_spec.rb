RSpec.describe Magick::Image, "#adaptive_threshold" do
  before do
    @img = described_class.new(20, 20)
  end

  it "works" do
    expect do
      res = @img.adaptive_threshold
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error
    expect { @img.adaptive_threshold(2) }.not_to raise_error
    expect { @img.adaptive_threshold(2, 4) }.not_to raise_error
    expect { @img.adaptive_threshold(2, 4, 1) }.not_to raise_error
    expect { @img.adaptive_threshold(2, 4, 1, 2) }.to raise_error(ArgumentError)
  end
end
