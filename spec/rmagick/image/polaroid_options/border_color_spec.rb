describe Magick::Image::PolaroidOptions, "#border_color" do
  it "works" do
    options = described_class.new

    expect { options.border_color = "gray50" }.not_to raise_error

    options.freeze
    expect { options.border_color = "gray50" }.to raise_error(FreezeError)
  end
end
