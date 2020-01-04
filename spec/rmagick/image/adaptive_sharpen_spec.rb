RSpec.describe Magick::Image, "#adaptive_sharpen" do
  before do
    @img = Magick::Image.new(20, 20)
  end

  it "works" do
    expect do
      res = @img.adaptive_sharpen
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
    expect { @img.adaptive_sharpen(2) }.not_to raise_error
    expect { @img.adaptive_sharpen(3, 2) }.not_to raise_error
    expect { @img.adaptive_sharpen(3, 2, 2) }.to raise_error(ArgumentError)
  end
end
