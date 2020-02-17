RSpec.describe Magick::Image, "#blur_image" do
  it "works" do
    image = described_class.new(20, 20)

    expect { image.blur_image }.not_to raise_error
    expect { image.blur_image(1) }.not_to raise_error
    expect { image.blur_image(1, 2) }.not_to raise_error
    expect { image.blur_image(1, 2, 3) }.to raise_error(ArgumentError)
    result = image.blur_image
    expect(result).to be_instance_of(described_class)
  end
end
