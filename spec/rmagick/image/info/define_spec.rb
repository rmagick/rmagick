# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#define' do
  it 'works' do
    info = described_class.new

    expect { info.define('tiff', 'bits-per-sample', 2) }.not_to raise_error
    expect { info.undefine('tiff', 'bits-per-sample') }.not_to raise_error
    expect { info.define('tiff', 'bits-per-sample', 2, 2) }.to raise_error(ArgumentError)
    expect { info.define('tiff', 'a' * 10_000) }.to raise_error(ArgumentError)
  end

  it 'defines an empty value without a value argument' do
    info = described_class.new

    info.define('tiff', 'rows-per-strip')
    expect(info['tiff', 'rows-per-strip']).to eq('')
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

  it "keeps the value when converting the key replaces the value" do
    info = described_class.new
    value = +"8"
    key = Object.new
    key.define_singleton_method(:to_str) do
      value.replace("z" * 5000)
      "rows-per-strip"
    end

    info.define("tiff", key, value)
    expect(info["tiff", "rows-per-strip"]).to eq("8")
  end

  it "keeps the key when converting the format replaces the key" do
    info = described_class.new
    key = +"rows-per-strip"
    format = Object.new
    format.define_singleton_method(:to_str) do
      key.replace("z" * 5000)
      "tiff"
    end

    info.define(format, key, "8")
    expect(info["tiff", "rows-per-strip"]).to eq("8")
  end

  it "keeps the format of #undefine when converting the key replaces the format" do
    info = described_class.new
    info["tiff", "rows-per-strip"] = "8"
    format = +"tiff"
    key = Object.new
    key.define_singleton_method(:to_str) do
      format.replace("z" * 5000)
      "rows-per-strip"
    end

    info.undefine(format, key)
    expect(info["tiff", "rows-per-strip"]).to be(nil)
  end

  # Regression: the format and key were read with a function that keeps a NUL
  # byte, so the "format:key" name was cut short at the NUL and a different
  # option was defined or undefined.
  it 'rejects a format or key that contains a NUL byte' do
    info = described_class.new

    expect { info.define("tiff\u0000evil", 'rows-per-strip', '8') }.to raise_error(ArgumentError)
    expect { info.define('tiff', "rows\u0000per", '8') }.to raise_error(ArgumentError)
    expect { info.undefine("tiff\u0000evil", 'rows-per-strip') }.to raise_error(ArgumentError)
    expect { info.undefine('tiff', "rows\u0000per") }.to raise_error(ArgumentError)
    expect(info['tiff', 'rows-per-strip']).to be(nil)
  end

  # Regression: #define rejected a long key that #[]= accepted, because the two
  # used different buffer sizes.
  it 'applies the same length limit as Info#[]=' do
    key = 'k' * 200

    defined = described_class.new
    aset = described_class.new
    defined.define('tiff', key, 'v')
    aset['tiff', key] = 'v'

    expect(defined['tiff', key]).to eq('v')
    expect(aset['tiff', key]).to eq('v')
  end
end
