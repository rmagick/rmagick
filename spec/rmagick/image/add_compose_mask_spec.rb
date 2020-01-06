RSpec.describe Magick::Image, "#add_compose_mask" do
  it "works" do
    img = described_class.new(20, 20)
    mask = described_class.new(20, 20)

    expect { img.add_compose_mask(mask) }.not_to raise_error
    expect { img.delete_compose_mask }.not_to raise_error
    expect { img.add_compose_mask(mask) }.not_to raise_error
    expect { img.add_compose_mask(mask) }.not_to raise_error
    expect { img.delete_compose_mask }.not_to raise_error
    expect { img.delete_compose_mask }.not_to raise_error

    mask = described_class.new(10, 10)
    expect { img.add_compose_mask(mask) }.to raise_error(ArgumentError)
  end
end
