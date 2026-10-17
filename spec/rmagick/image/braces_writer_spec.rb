# frozen_string_literal: true

RSpec.describe Magick::Image, "#[]=" do
  it "works" do
    image = described_class.new(20, 20)

    image['label'] = 'foobarbaz'
    image[:comment] = 'Hello world'
    expect(image['label']).to eq('foobarbaz')
    expect(image['comment']).to eq('Hello world')
    expect { image[nil] = 'foobarbaz' }.not_to raise_error
  end

  it "keeps the value when converting the key replaces the value" do
    image = described_class.new(4, 4)
    value = "a" * 3000
    key = Object.new
    key.define_singleton_method(:to_str) do
      value.replace("z" * 5000)
      "comment"
    end

    image[key] = value
    expect(image["comment"]).to eq("a" * 3000)
  end
end
