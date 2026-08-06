# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#define' do
  it 'works' do
    info = described_class.new

    expect { info.define('tiff', 'bits-per-sample', 2) }.not_to raise_error
    expect { info.undefine('tiff', 'bits-per-sample') }.not_to raise_error
    expect { info.define('tiff', 'bits-per-sample', 2, 2) }.to raise_error(ArgumentError)
    expect { info.define('tiff', 'a' * 10_000) }.to raise_error(ArgumentError)
  end

  it 'copies the image option to an artifact keyed by the option name' do
    image = Magick::Image.new(50, 50)
    image.to_blob do |info|
      info.format = 'PNG'
      info.define('reg', 'probe', 'HELLOARTIFACT')
    end

    expect(image.artifact('reg:probe')).to eq('HELLOARTIFACT')

    # The value must not be used as the artifact key.
    expect(image.artifact('HELLOARTIFACT')).to be(nil)
  end

  # Regression: see the matching example in braces_spec.rb. The option used to
  # be defined and undefined under a corrupted key.
  it 'accepts arguments that respond to #to_str' do
    with_gc_stress do
      10.times do
        info = described_class.new
        info.define(ToStrDuck.new('tiff'), ToStrDuck.new('rows-per-strip'), '8')
        expect(info['tiff', 'rows-per-strip']).to eq('8')

        info.undefine(ToStrDuck.new('tiff'), ToStrDuck.new('rows-per-strip'))
        expect(info['tiff', 'rows-per-strip']).to be(nil)
      end
    end
  end
end
