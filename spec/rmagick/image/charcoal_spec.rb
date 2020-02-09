RSpec.describe Magick::Image, "#charcoal" do
  before do
    @img = described_class.new(20, 20)
  end

  it "works" do
    expect do
      res = @img.charcoal
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error
    expect { @img.charcoal }.not_to raise_error
    expect { @img.charcoal(1.0) }.not_to raise_error
    expect { @img.charcoal(1.0, 2.0) }.not_to raise_error
    expect { @img.charcoal(1.0, 2.0, 3.0) }.to raise_error(ArgumentError)
  end
end
