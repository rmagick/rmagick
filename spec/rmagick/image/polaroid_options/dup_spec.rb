# frozen_string_literal: true

RSpec.describe Magick::Image::PolaroidOptions, '#dup' do
  it 'copies the settings' do
    image = Magick::Image.new(20, 20)
    options = described_class.new
    options.shadow_color = 'red'
    options.border_color = 'blue'
    expected = image.polaroid(0) do |given|
      given.shadow_color = 'red'
      given.border_color = 'blue'
    end

    [options.dup, options.clone].each do |copy|
      result = image.polaroid(0) { |given| given.__send__(:initialize_copy, copy) }
      expect(result.export_pixels).to eq(expected.export_pixels)
    end
  end

  it 'raises TypeError when initialize_copy is called with a Draw' do
    expect { described_class.allocate.__send__(:initialize_copy, Magick::Draw.new) }.to raise_error(TypeError)
  end
end
