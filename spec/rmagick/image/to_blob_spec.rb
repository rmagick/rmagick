# frozen_string_literal: true

RSpec.describe Magick::Image, '#to_blob' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.to_blob { |options| options.format = 'miff' }
    expect(result).to be_instance_of(String)
    restored = described_class.from_blob(result)
    expect(restored[0]).to eq(image)
  end

  it "leaves a frozen image unchanged" do
    image = described_class.new(20, 20).freeze

    blob = image.to_blob { |options| options.format = "PNG" }
    expect(described_class.from_blob(blob).first.format).to eq("PNG")
    expect(image.format).to be(nil)
  end

  it "releases what it holds when one of its calls is interrupted" do
    image = described_class.new(4, 4)
    calls = interrupt_each_call(Class.new(StandardError)) do
      image.to_blob do |options|
        options.format = "MIFF"
        options.colorspace = Magick::GRAYColorspace
      end
    end

    expect(calls).to be_positive
  end
end
