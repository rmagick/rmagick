RSpec.describe Magick::Image, "#black_threshold" do
  before do
    @img = described_class.new(20, 20)
  end

  it "works" do
    expect { @img.black_threshold }.to raise_error(ArgumentError)
    expect { @img.black_threshold(50) }.not_to raise_error
    expect { @img.black_threshold(50, 50) }.not_to raise_error
    expect { @img.black_threshold(50, 50, 50) }.not_to raise_error
    expect { @img.black_threshold(50, 50, 50, 50) }.to raise_error(ArgumentError)
    expect { @img.black_threshold(50, 50, 50, alpha: 50) }.not_to raise_error
    expect { @img.black_threshold(50, 50, 50, wrong: 50) }.to raise_error(ArgumentError)
    expect { @img.black_threshold(50, 50, 50, alpha: 50, extra: 50) }.to raise_error(ArgumentError)
    expect { @img.black_threshold(50, 50, 50, 50, 50) }.to raise_error(ArgumentError)
    res = @img.black_threshold(50)
    expect(res).to be_instance_of(described_class)
  end
end
