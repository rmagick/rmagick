describe Magick::Image::PolaroidOptions, "#shadow_color" do
  before do
    @options = described_class.new
  end

  it "works" do
    expect { @options.shadow_color = "gray50" }.not_to raise_error

    @options.freeze
    expect { @options.shadow_color = "gray50" }.to raise_error(FreezeError)
  end
end
