# frozen_string_literal: true

RSpec.describe Magick::Image, '#class_type' do
  it "returns the class_type for an image" do
    image = build_image

    expect(image.class_type).to eq(Magick::DirectClass)
  end

  it "returns the class_type assigned" do
    image = build_image

    image.class_type = Magick::PseudoClass

    expect(image.class_type).to eq(Magick::PseudoClass)
  end
end
