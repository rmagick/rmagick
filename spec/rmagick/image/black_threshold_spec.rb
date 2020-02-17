RSpec.describe Magick::Image, "#black_threshold" do
  it "works" do
    image = described_class.new(20, 20)

    expect { image.black_threshold }.to raise_error(ArgumentError)
    expect { image.black_threshold(50) }.not_to raise_error
    expect { image.black_threshold(50, 50) }.not_to raise_error
    expect { image.black_threshold(50, 50, 50) }.not_to raise_error
    expect { image.black_threshold(50, 50, 50, 50) }.to raise_error(ArgumentError)
    expect { image.black_threshold(50, 50, 50, alpha: 50) }.not_to raise_error
    expect { image.black_threshold(50, 50, 50, wrong: 50) }.to raise_error(ArgumentError)
    expect { image.black_threshold(50, 50, 50, alpha: 50, extra: 50) }.to raise_error(ArgumentError)
    expect { image.black_threshold(50, 50, 50, 50, 50) }.to raise_error(ArgumentError)
    result = image.black_threshold(50)
    expect(result).to be_instance_of(described_class)
  end
end
