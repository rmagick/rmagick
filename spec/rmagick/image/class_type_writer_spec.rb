# frozen_string_literal: true

RSpec.describe Magick::Image, '#class_type=' do
  it "sets the class_type for an image" do
    image = build_image

    expect { image.class_type = Magick::PseudoClass }
      .to change(image, :class_type)
      .from(Magick::DirectClass).to(Magick::PseudoClass)
  end

  it "does not allow setting to UndefinedClass" do
    image = build_image

    expect { image.class_type = Magick::UndefinedClass }
      .to raise_error(ArgumentError, 'Invalid class type specified.')
  end

  context "when class_type changes from PseudoClass to DirectClass" do
    it "preserves the pixel values" do
      image = build_image
      image.class_type = Magick::PseudoClass
      expected_pixels = image.export_pixels

      image.class_type = Magick::DirectClass

      expect(image).to match_pixels(expected_pixels)
    end

    it "removes the colormap" do
      image = build_image
      image.class_type = Magick::PseudoClass
      expect { image.colormap(0) }.not_to raise_error

      image.class_type = Magick::DirectClass

      expect { image.colormap(0) }.to raise_error(IndexError, "image does not contain a colormap")
    end

    it "sets the class_type" do
      image = build_image
      image.class_type = Magick::PseudoClass

      expect { image.class_type = Magick::DirectClass }
        .to change(image, :class_type)
        .from(Magick::PseudoClass).to(Magick::DirectClass)
    end
  end

  context "when class_type changes from DirectClass to PseudoClass" do
    it "quantizes the image, changing the pixels", unsupported_before("7.0.0") do
      image = build_image

      expected_pixels = [26, 81, 201] * 4
      expect { image.class_type = Magick::PseudoClass }
        .to change(image, :export_pixels).to(expected_pixels)
    end

    it "quantizes the image, not changing the pixels", supported_before("7.0.0") do
      image = build_image

      expect { image.class_type = Magick::PseudoClass }
        .not_to change(image, :export_pixels)
    end

    it "creates a colormap" do
      image = build_image

      expect { image.colormap(0) }.to raise_error(IndexError, "image does not contain a colormap")
      image.class_type = Magick::PseudoClass

      expect { image.colormap(0) }.not_to raise_error
    end

    it "sets the class_type" do
      image = build_image

      expect { image.class_type = Magick::PseudoClass }
        .to change(image, :class_type)
        .from(Magick::DirectClass).to(Magick::PseudoClass)
    end
  end
end
