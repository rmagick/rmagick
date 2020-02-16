RSpec.describe Magick::Image, "#blur_image" do
  it "works" do
    img = described_class.new(20, 20)

    expect { img.blur_image }.not_to raise_error
    expect { img.blur_image(1) }.not_to raise_error
    expect { img.blur_image(1, 2) }.not_to raise_error
    expect { img.blur_image(1, 2, 3) }.to raise_error(ArgumentError)
    res = img.blur_image
    expect(res).to be_instance_of(described_class)
  end
end
