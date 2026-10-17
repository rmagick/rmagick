# frozen_string_literal: true

describe Magick::Image::PolaroidOptions, "#border_color" do
  it "works" do
    options = described_class.new

    expect { options.border_color = "gray50" }.not_to raise_error

    options.freeze
    expect { options.border_color = "gray50" }.to raise_error(FrozenError)
  end

  it "raises an error when converting the color freezes the options" do
    options = described_class.new
    color = Object.new
    color.define_singleton_method(:to_str) do
      options.freeze
      "gray50"
    end

    expect { options.border_color = color }.to raise_error(FrozenError)
  end
end
