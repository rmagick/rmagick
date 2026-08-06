# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#[]' do
  it 'works' do
    info = described_class.new

    # 1-argument form
    expect { info['fill'] }.not_to raise_error
    expect(info['fill']).to be(nil)

    expect { info['fill'] = 'red' }.not_to raise_error
    expect(info['fill']).to eq('red')

    expect { info['fill'] = nil }.not_to raise_error
    expect(info['fill']).to be(nil)

    # 2-argument form
    expect { info['tiff', 'bits-per-sample'] = 2 }.not_to raise_error
    expect(info['tiff', 'bits-per-sample']).to eq('2')

    # define and undefine
    expect { info.define('tiff', 'bits-per-sample', 4) }.not_to raise_error
    expect(info['tiff', 'bits-per-sample']).to eq('4')

    expect { info.undefine('tiff', 'bits-per-sample') }.not_to raise_error
    expect(info['tiff', 'bits-per-sample']).to be(nil)
    expect { info.undefine('tiff', 'a' * 10_000) }.to raise_error(ArgumentError)
  end

  # Regression: rm_str2cstr took its argument by value, so the String that
  # #to_str produced was referenced by nothing once it returned and the GC was
  # free to recycle it. The option was then looked up under a corrupted key.
  it 'accepts arguments that respond to #to_str' do
    info = described_class.new
    info['tiff', 'rows-per-strip'] = '8'

    with_gc_stress do
      10.times do
        expect(info[ToStrDuck.new('tiff'), ToStrDuck.new('rows-per-strip')]).to eq('8')
      end
    end
  end
end
