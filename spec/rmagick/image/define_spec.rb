# frozen_string_literal: true

RSpec.describe Magick::Image, '#define' do
  it 'works' do
    image = described_class.new(20, 20)

    expect { image.define('deskew:auto-crop', 40) }.not_to raise_error
    expect { image.undefine('deskew:auto-crop') }.not_to raise_error
    expect { image.define('deskew:auto-crop', nil) }.not_to raise_error
  end

  it "keeps the key when converting the value replaces the key" do
    image = described_class.new(4, 4)
    key = "k" * 3000
    value = Object.new
    value.define_singleton_method(:to_str) do
      key.replace("z" * 5000)
      "v"
    end

    image.define(key, value)
    expect(image.artifact("k" * 3000)).to eq("v")
  end
end
