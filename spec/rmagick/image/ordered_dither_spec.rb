# frozen_string_literal: true

RSpec.describe Magick::Image, '#ordered_dither' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.ordered_dither
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.ordered_dither('3x3') }.not_to raise_error
    expect { image.ordered_dither(2) }.not_to raise_error
    expect { image.ordered_dither(3) }.not_to raise_error
    expect { image.ordered_dither(4) }.not_to raise_error
    expect { image.ordered_dither(5) }.to raise_error(ArgumentError)
    expect { image.ordered_dither(2, 1) }.to raise_error(ArgumentError)
  end

  it 'reads the threshold map when the GC compacts while it runs', if: GCCompaction.moves_arguments? do
    image = described_class.new(8, 8)
    expected = image.ordered_dither('3x3')
    results = []

    with_gc_compaction do
      10.times { results << image.ordered_dither(+'3x3') }
    end

    expect(results).to eq([expected] * 10)
  end
end
