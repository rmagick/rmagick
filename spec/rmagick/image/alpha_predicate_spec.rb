RSpec.describe Magick::Image, "#alpha?" do
  it "works" do
    img = described_class.new(20, 20)

    expect { img.alpha? }.not_to raise_error
    expect(img.alpha?).to be(false)
    expect { img.alpha Magick::ActivateAlphaChannel }.not_to raise_error
    expect(img.alpha?).to be(true)
    expect { img.alpha Magick::DeactivateAlphaChannel }.not_to raise_error
    expect(img.alpha?).to be(false)
    expect { img.alpha Magick::OpaqueAlphaChannel }.not_to raise_error
    expect { img.alpha Magick::SetAlphaChannel }.not_to raise_error
    expect { img.alpha Magick::SetAlphaChannel, Magick::OpaqueAlphaChannel }.to raise_error(ArgumentError)
    img.freeze
    expect { img.alpha Magick::SetAlphaChannel }.to raise_error(FreezeError)
  end
end
