RSpec.describe Magick::Image, "#alpha?" do
  it "works" do
    image = described_class.new(20, 20)

    expect { image.alpha? }.not_to raise_error
    expect(image.alpha?).to be(false)
    expect { image.alpha Magick::ActivateAlphaChannel }.not_to raise_error
    expect(image.alpha?).to be(true)
    expect { image.alpha Magick::DeactivateAlphaChannel }.not_to raise_error
    expect(image.alpha?).to be(false)
    expect { image.alpha Magick::OpaqueAlphaChannel }.not_to raise_error
    expect { image.alpha Magick::SetAlphaChannel }.not_to raise_error
    expect { image.alpha Magick::SetAlphaChannel, Magick::OpaqueAlphaChannel }.to raise_error(ArgumentError)
    image.freeze
    expect { image.alpha Magick::SetAlphaChannel }.to raise_error(FreezeError)
  end
end
