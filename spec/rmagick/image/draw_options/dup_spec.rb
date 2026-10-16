# frozen_string_literal: true

RSpec.describe Magick::Image::DrawOptions, '#dup' do
  it 'returns options that can be changed' do
    options = described_class.new
    options.fill = 'red'

    [options.dup, options.clone].each do |copy|
      expect { copy.stroke = 'blue' }.not_to raise_error
    end
  end

  it 'raises TypeError when initialize_copy is called with a Draw' do
    expect { described_class.allocate.__send__(:initialize_copy, Magick::Draw.new) }.to raise_error(TypeError)
  end

  it 'raises FrozenError when initialize_copy is called on frozen options' do
    options = described_class.new.freeze

    expect { options.__send__(:initialize_copy, described_class.new) }.to raise_error(FrozenError)
  end
end
