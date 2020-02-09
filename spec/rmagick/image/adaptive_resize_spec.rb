RSpec.describe Magick::Image, "#adaptive_resize" do
  before do
    @img = described_class.new(20, 20)
  end

  it "works" do
    expect do
      res = @img.adaptive_resize(10, 10)
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error
    expect { @img.adaptive_resize(2) }.not_to raise_error
    expect { @img.adaptive_resize(-1.0) }.to raise_error(ArgumentError)
    expect { @img.adaptive_resize(10, 10, 10) }.to raise_error(ArgumentError)
    expect { @img.adaptive_resize }.to raise_error(ArgumentError)
    expect { @img.adaptive_resize(Float::MAX) }.to raise_error(RangeError)
  end
end
