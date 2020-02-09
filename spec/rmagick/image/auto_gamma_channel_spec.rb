RSpec.describe Magick::Image, "#auto_gamma_channel" do
  before do
    @img = described_class.new(20, 20)
  end

  it "works" do
    res = nil
    expect { res = @img.auto_gamma_channel }.not_to raise_error
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(@img)
    expect { res = @img.auto_gamma_channel Magick::RedChannel }.not_to raise_error
    expect { res = @img.auto_gamma_channel Magick::RedChannel, Magick::BlueChannel }.not_to raise_error
    expect { @img.auto_gamma_channel(1) }.to raise_error(TypeError)
  end
end
