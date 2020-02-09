RSpec.describe Magick::Image, "#affine_transform" do
  before do
    @img = described_class.new(20, 20)
  end

  it "works" do
    affine = Magick::AffineMatrix.new(1, Math::PI / 6, Math::PI / 6, 1, 0, 0)
    expect { @img.affine_transform(affine) }.not_to raise_error
    expect { @img.affine_transform(0) }.to raise_error(TypeError)
    res = @img.affine_transform(affine)
    expect(res).to be_instance_of(described_class)
  end
end
