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

  it "accepts a subclass of AffineMatrix and an AffineMatrix with a singleton method" do
    image = described_class.new(20, 20)
    subclass = Class.new(Magick::AffineMatrix).new(1, 0, 0, 1, 0, 0)
    singleton = Magick::AffineMatrix.new(1, 0, 0, 1, 0, 0)
    singleton.define_singleton_method(:label) { 'identity' }

    expect(image.affine_transform(subclass)).to be_instance_of(described_class)
    expect(image.affine_transform(singleton)).to be_instance_of(described_class)
  end
end
