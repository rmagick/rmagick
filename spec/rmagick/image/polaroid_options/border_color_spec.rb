describe Magick::Image::PolaroidOptions, "#border_color" do
  before do
    @options = Magick::Image::PolaroidOptions.new
  end

  it "works" do
    expect { @options.border_color = "gray50" }.not_to raise_error

    @options.freeze
    expect { @options.border_color = "gray50" }.to raise_error(FreezeError)
  end
end
