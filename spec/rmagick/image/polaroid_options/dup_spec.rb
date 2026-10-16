# frozen_string_literal: true

RSpec.describe Magick::Image::PolaroidOptions, '#dup' do
  it 'returns options that can be changed' do
    options = described_class.new
    options.shadow_color = 'blue'

    [options.dup, options.clone].each do |copy|
      expect { copy.border_color = 'red' }.not_to raise_error
    end
  end

  it 'raises TypeError when initialize_copy is called with a Draw' do
    expect { described_class.allocate.__send__(:initialize_copy, Magick::Draw.new) }.to raise_error(TypeError)
  end
end
