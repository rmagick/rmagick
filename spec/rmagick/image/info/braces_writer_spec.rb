# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#[]=' do
  it 'works' do
    info = described_class.new

    expect { info['tiff'] = 'xxx' }.not_to raise_error
    expect(info['tiff']).to eq('xxx')
    expect { info['tiff', 'bits-per-sample'] = 'abc' }.not_to raise_error
    expect(info['tiff', 'bits-per-sample']).to eq('abc')
    expect { info['tiff', 'a', 'b'] }.to raise_error(ArgumentError)
    expect { info['tiff', 'a' * 10_000] }.to raise_error(ArgumentError)
    expect { info['tiff', 'a' * 10_000] = 'abc' }.to raise_error(ArgumentError)
    expect { info['tiff', 'a', 'b'] = 'abc' }.to raise_error(ArgumentError)
  end

  # Regression: see the matching example in braces_spec.rb. The option used to
  # be stored under a corrupted key.
  it 'accepts arguments that respond to #to_str' do
    with_gc_stress do
      10.times do
        info = described_class.new
        info[ToStrDuck.new('tiff'), ToStrDuck.new('rows-per-strip')] = '8'

        expect(info['tiff', 'rows-per-strip']).to eq('8')
      end
    end
  end
end
