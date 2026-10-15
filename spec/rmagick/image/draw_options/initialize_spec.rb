# frozen_string_literal: true

RSpec.describe Magick::Image::DrawOptions, '#initialize' do
  it 'releases the DrawInfo it held when initialize is called again' do
    options = described_class.new
    options.fill_pattern = Magick::Image.new(1000, 1000)
    GC.start
    baseline = Magick.resource_usage(:memory)

    options.__send__(:initialize)

    expect(Magick.resource_usage(:memory)).to be < baseline
  end

  it 'raises FrozenError when initialize is called on frozen options' do
    options = described_class.new.freeze

    expect { options.__send__(:initialize) }.to raise_error(FrozenError)
  end
end
