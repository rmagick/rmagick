# frozen_string_literal: true

RSpec.describe Magick::Image, "#color_histogram" do
  it "works" do
    image = described_class.new(20, 20)

    result = image.color_histogram
    expect(result).to be_instance_of(Hash)

    image.class_type = Magick::PseudoClass
    result = image.color_histogram
    expect(image.class_type).to eq(Magick::PseudoClass)
    expect(result).to be_instance_of(Hash)
  end

  it 'keeps black of a CMYK image' do
    image = described_class.new(1, 1) { |options| options.background_color = 'black' }
    image.colorspace = Magick::CMYKColorspace

    expect(image.color_histogram.keys.map(&:black)).to eq([Magick::QuantumRange])
  end

  it "releases what it holds when one of its calls is interrupted" do
    image = described_class.new(4, 4)
    image.class_type = Magick::PseudoClass

    expect(interrupt_each_call(Class.new(StandardError)) { image.color_histogram }).to be_positive
  end
end
