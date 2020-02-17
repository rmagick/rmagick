RSpec.describe Magick::Image, "#add_compose_mask" do
  it "works" do
    image = described_class.new(20, 20)
    mask = described_class.new(20, 20)

    expect { image.add_compose_mask(mask) }.not_to raise_error
    expect { image.delete_compose_mask }.not_to raise_error
    expect { image.add_compose_mask(mask) }.not_to raise_error
    expect { image.add_compose_mask(mask) }.not_to raise_error
    expect { image.delete_compose_mask }.not_to raise_error
    expect { image.delete_compose_mask }.not_to raise_error

    mask = described_class.new(10, 10)
    expect { image.add_compose_mask(mask) }.to raise_error(ArgumentError)
  end
end
