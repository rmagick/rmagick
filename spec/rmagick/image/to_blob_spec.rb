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
end
