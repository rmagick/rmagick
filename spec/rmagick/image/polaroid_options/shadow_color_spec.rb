describe Magick::Image::PolaroidOptions, "#shadow_color" do
  it "works" do
    options = described_class.new

    expect { options.shadow_color = "gray50" }.not_to raise_error

    options.freeze
    expect { options.shadow_color = "gray50" }.to raise_error(FreezeError)
  end
end
