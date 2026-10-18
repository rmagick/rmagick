# frozen_string_literal: true

RSpec.describe Magick::Image, "#affine_transform" do
  it "works" do
    image = described_class.new(20, 20)

    affine = Magick::AffineMatrix.new(1, Math::PI / 6, Math::PI / 6, 1, 0, 0)
    expect { image.affine_transform(affine) }.not_to raise_error
    expect { image.affine_transform(0) }.to raise_error(TypeError)
    result = image.affine_transform(affine)
    expect(result).to be_instance_of(described_class)
  end

  it "raises TypeError when AffineMatrix#values does not return an Array" do
    image = described_class.new(20, 20)
    affine = Magick::AffineMatrix.new(1, 0, 0, 1, 0, 0)
    allow_any_instance_of(Magick::AffineMatrix).to receive(:values).and_return(nil) # rubocop:disable RSpec/AnyInstance

    expect { image.affine_transform(affine) }
      .to raise_error(TypeError, "Magick::AffineMatrix#values must return an Array (NilClass given)")
  end
end
