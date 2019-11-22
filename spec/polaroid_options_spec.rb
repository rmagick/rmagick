RSpec.describe Magick::Image::PolaroidOptions do
  before do
    @options = Magick::Image::PolaroidOptions.new
  end

  describe "#shadow_color" do
    it "works" do
      expect { @options.shadow_color = "gray50" }.not_to raise_error

      @options.freeze
      expect { @options.shadow_color = "gray50" }.to raise_error(FreezeError)
    end
  end

  describe "#border_color" do
    it "works" do
      expect { @options.border_color = "gray50" }.not_to raise_error

      @options.freeze
      expect { @options.border_color = "gray50" }.to raise_error(FreezeError)
    end
  end
end
