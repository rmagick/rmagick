# frozen_string_literal: true

RSpec.describe Magick::GradientFill, '#dup' do
  it 'copies the gradient' do
    fill = described_class.new(0, 0, 0, 4, 'red', 'blue')
    expected = Magick::Image.new(4, 4)
    fill.fill(expected)

    [fill.dup, fill.clone].each do |copy|
      image = Magick::Image.new(4, 4)
      copy.fill(image)
      expect(image.export_pixels_to_str).to eq(expected.export_pixels_to_str)
    end
  end

  it 'raises FrozenError when initialize_copy is called on a frozen fill' do
    fill = described_class.new(0, 0, 0, 4, 'red', 'blue').freeze

    expect { fill.__send__(:initialize_copy, described_class.new(0, 0, 4, 0, 'green', 'white')) }.to raise_error(FrozenError)
  end
end
