# frozen_string_literal: true

RSpec.describe Magick::Draw, '#marshal_load' do
  it 'round-trips a dumped Draw' do
    draw = described_class.new
    draw.fill = Magick::Pixel.from_color('red')

    expect { described_class.new.marshal_load(draw.marshal_dump) }.not_to raise_error
  end

  it 'keeps black of the fill color', if: Gem::Version.new(Magick::IMAGEMAGICK_VERSION) >= Gem::Version.new('7.0.0') do
    fill = Magick::Pixel.new(0, 0, 0)
    fill.black = 1000
    draw = described_class.new
    draw.fill = fill

    expect(Marshal.load(Marshal.dump(draw)).marshal_dump[:fill]).to eq(fill)
  end

  # Regression: a non-Hash argument used to be dereferenced as a Hash and crash
  # the process (SIGSEGV). It must raise TypeError instead.
  it 'raises TypeError for a non-Hash argument' do
    draw = described_class.new
    expect { draw.marshal_load(0) }.to raise_error(TypeError)
    expect { draw.marshal_load(nil) }.to raise_error(TypeError)
    expect { draw.marshal_load([]) }.to raise_error(TypeError)
  end

  # Regression: a non-String pattern used to be reinterpreted as a String, so
  # its buffer pointer and length were read from unrelated object fields and
  # handed to BlobToImage. It must raise TypeError instead.
  it 'raises TypeError for a pattern that is not a String' do
    dumped = described_class.new.marshal_dump

    [0, :symbol, [1, 'x'], {}].each do |value|
      expect { described_class.new.marshal_load(dumped.merge(fill_pattern: value)) }.to raise_error(TypeError)
      expect { described_class.new.marshal_load(dumped.merge(stroke_pattern: value)) }.to raise_error(TypeError)
    end
  end

  it 'loads every dumped value into an initialized Draw' do
    source = described_class.new
    source.affine = Magick::AffineMatrix.new(1, 2, 3, 4, 5, 6)
    source.decorate = Magick::LineThroughDecoration
    source.encoding = 'AdobeCustom'
    source.gravity = Magick::CenterGravity
    source.fill = Magick::Pixel.from_color('red')
    source.stroke = Magick::Pixel.from_color('blue')
    source.stroke_width = 5
    source.text_antialias = false
    source.font = 'Arial-Bold'
    source.font_family = 'arial'
    source.font_style = Magick::ItalicStyle
    source.font_stretch = Magick::CondensedStretch
    source.font_weight = Magick::BoldWeight
    source.pointsize = 20
    source.density = '72x72'
    source.align = Magick::CenterAlign
    source.undercolor = Magick::Pixel.from_color('green')
    source.kerning = 10.5
    source.interword_spacing = 3.75
    source.circle(20, 25, 20, 28)
    dumped = source.marshal_dump

    draw = described_class.new
    draw.marshal_load(dumped)

    expect(draw.marshal_dump).to eq(dumped)
  end

  it 'raises FrozenError for a frozen Draw and leaves it unchanged' do
    source = described_class.new
    source.pointsize = 99
    draw = described_class.new.freeze
    before = draw.marshal_dump

    expect { draw.marshal_load(source.marshal_dump) }.to raise_error(FrozenError)
    expect(draw.marshal_dump).to eq(before)
  end

  it 'raises FrozenError when converting a value freezes the Draw' do
    draw = described_class.new
    before = draw.marshal_dump
    pointsize = Struct.new(:draw) do
      def to_f
        draw.freeze && 30.0
      end
    end.new(draw)

    expect { draw.marshal_load(before.merge(pointsize: pointsize)) }.to raise_error(FrozenError)
    expect(draw.marshal_dump).to eq(before)
  end

  it 'leaves the Draw unchanged when a value cannot be converted' do
    draw = described_class.new
    draw.font = 'Helvetica'
    before = draw.marshal_dump

    [
      { affine: Magick::AffineMatrix.new(2.0, 0.0, 0.0, 2.0, 5.0, 'x') },
      { font: nil, stroke_width: 7.0, kerning: 'x' }
    ].each do |change|
      expect { draw.marshal_load(before.merge(change)) }.to raise_error(TypeError)
      expect(draw.marshal_dump).to eq(before)
    end
  end

  it 'keeps the values it does not load, even one set while it converts a value' do
    draw = described_class.new
    pointsize = Struct.new(:draw) do
      def to_f
        draw.interline_spacing = 40
        12.0
      end
    end.new(draw)

    draw.marshal_load(draw.marshal_dump.merge(pointsize: pointsize))

    spaced = described_class.new
    spaced.interline_spacing = 40
    height = draw.get_multiline_type_metrics("a\nb").height
    expect(height).to eq(spaced.get_multiline_type_metrics("a\nb").height)
    expect(height).not_to eq(described_class.new.get_multiline_type_metrics("a\nb").height)
  end

  it 'replaces the patterns and the font it already has' do
    pattern = Magick::Image.new(4, 4)
    pattern.format = 'MIFF'
    draw = described_class.new
    draw.fill_pattern = pattern
    draw.stroke_pattern = pattern
    draw.font = 'Helvetica'

    draw.marshal_load(draw.marshal_dump)
    expect(draw.marshal_dump[:fill_pattern]).not_to be(nil)

    draw.marshal_load(described_class.new.marshal_dump)
    dumped = draw.marshal_dump
    expect(dumped[:fill_pattern]).to be(nil)
    expect(dumped[:stroke_pattern]).to be(nil)
    expect(dumped[:font]).to be(nil)
  end

  it 'does not share the primitives with the Hash' do
    source = described_class.new
    source.point(0, 0)
    dumped = source.marshal_dump
    draw = described_class.new
    draw.marshal_load(dumped)

    dumped[:primitives] << "\nline 0,0 9,9"

    expect(draw.inspect).to eq('point 0,0')
  end

  it 'keeps only the first image of a pattern that reads back as several images' do
    pattern = Magick::Image.new(100, 100)
    pattern.format = 'PSD'
    draw = described_class.new
    draw.fill_pattern = pattern
    draw.stroke_pattern = pattern
    dumped = draw.marshal_dump
    loaded = described_class.new
    loaded.marshal_load(dumped)
    GC.start
    before = pixel_cache_size

    5.times { loaded.marshal_load(dumped) }

    expect(pixel_cache_size).to eq(before)
  end
end
