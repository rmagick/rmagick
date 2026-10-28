# frozen_string_literal: true

RSpec.describe Magick::Image, "#colormap" do
  it "works" do
    image = described_class.new(20, 20)

    # IndexError b/c image is DirectClass
    expect { image.colormap(0) }.to raise_error(IndexError)
    # Read PseudoClass image
    pc_image = described_class.read(IMAGES_DIR + '/Button_0.gif') { |info| info.depth = 8 }.first
    expect { pc_image.colormap(0) }.not_to raise_error
    ncolors = pc_image.colors
    expect { pc_image.colormap(ncolors + 1) }.to raise_error(IndexError)
    expect { pc_image.colormap(-1) }.to raise_error(IndexError)
    expect { pc_image.colormap(ncolors - 1) }.not_to raise_error
    result = pc_image.colormap(0)
    expect(result).to be_instance_of(String)

    # test 'set' operation
    old_color = pc_image.colormap(0)
    result = pc_image.colormap(0, 'red')
    expect(result).to eq(old_color)
    result = pc_image.colormap(0)
    expect(result).to eq('#FF0000FF')

    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { pc_image.colormap(0, pixel) }.not_to raise_error
    expect { pc_image.colormap }.to raise_error(ArgumentError)
    expect { pc_image.colormap(0, pixel, Magick::BlackChannel) }.to raise_error(ArgumentError)
    expect { pc_image.colormap(0, [2]) }.to raise_error(TypeError)
    pc_image.freeze
    expect { pc_image.colormap(0, 'red') }.to raise_error(FrozenError)
  end

  # Regression: growing the colormap filled [colors, idx) with black and left
  # entry idx untouched, so the previous colour handed back to the caller was
  # whatever the freshly allocated heap held. Entry idx - 1 is one the fill loop
  # did write, so it says what black renders as on either ImageMagick version.
  it 'reports black as the previous colour of an entry it just created' do
    pc_image = described_class.read(IMAGES_DIR + '/Button_0.gif') { |info| info.depth = 8 }.first
    idx = pc_image.colors + 40

    previous = pc_image.colormap(idx, 'red')

    expect(previous).to eq(pc_image.colormap(idx - 1))
    expect(pc_image.colors).to eq(idx + 1)
    expect(pc_image.colormap(idx)).to eq('#FF0000FF')
  end

  def cmyk_colormap_image
    image = described_class.new(1, 1) do |info|
      info.depth = 16
      info.background_color = 'red'
    end
    image.colorspace = Magick::CMYKColorspace
    image.quantize(2, Magick::CMYKColorspace)
  end

  it 'returns the name in sRGB for a CMYK image' do
    image = cmyk_colormap_image

    expect(image.colormap(0)).to eq('#FFFF00000000FFFF')
    expect(image.colormap(0, 'green')).to eq('#FFFF00000000FFFF')
  end

  it 'converts a color name to CMYK for a CMYK image' do
    image = cmyk_colormap_image
    image.colormap(0, 'green')

    expect(image.colormap(0)).to eq('#000080800000FFFF')
    image.colormap(0, image.colormap(0))
    expect(image.colormap(0)).to eq('#000080800000FFFF')
  end

  it 'uses a Pixel as the channel values of a CMYK image' do
    image = cmyk_colormap_image
    image.colormap(0, Magick::Pixel.new(Magick::QuantumRange, 0, Magick::QuantumRange))

    expect(image.colormap(0)).to eq('#0000FFFF0000FFFF')
  end

  it 'keeps the black of a Pixel for a CMYK image' do
    image = cmyk_colormap_image
    pixel = Magick::Pixel.new(Magick::QuantumRange, 0, Magick::QuantumRange)
    pixel.black = Magick::QuantumRange / 2
    image.colormap(0, pixel)

    expect(image.colormap(0)).to eq('#000080000000FFFF')
  end

  it 'converts a CMYK color name to sRGB for other images' do
    image = described_class.new(1, 1) { |info| info.depth = 16 }.quantize(2)
    image.colormap(0, 'cmyk(100%,0,0,0)')

    expect(image.colormap(0)).to eq('#0000FFFFFFFFFFFF')
  end
end
