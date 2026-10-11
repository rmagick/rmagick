# frozen_string_literal: true

RSpec.describe Magick::Image, '#signature' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.signature
    expect(result).to be_instance_of(String)
  end

  it "leaves a frozen image unchanged" do
    image = described_class.new(20, 20).freeze

    expect(image.signature).to eq(described_class.new(20, 20).signature)
    expect(image.properties).to be_empty
  end
end
