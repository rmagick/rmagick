# frozen_string_literal: true

RSpec.describe Magick::Image, '#dup' do
  it 'works' do
    image = described_class.new(20, 20)

    ditto = image.dup
    expect(ditto).to eq(image)
  end

  it 'releases the image it held when initialize_copy is called again' do
    image = described_class.new(1000, 1000)
    other = described_class.new(1000, 1000)
    GC.start
    baseline = Magick.resource_usage(:memory)

    image.__send__(:initialize_copy, other)

    expect(Magick.resource_usage(:memory)).to be <= baseline
  end

  it 'raises FrozenError when initialize_copy is called on a frozen image' do
    image = described_class.new(2, 2).freeze

    expect { image.__send__(:initialize_copy, described_class.new(5, 5)) }.to raise_error(FrozenError)
    expect(image.columns).to eq(2)
  end
end
