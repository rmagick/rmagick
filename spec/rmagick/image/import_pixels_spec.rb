RSpec.describe Magick::Image, '#import_pixels' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    pixels = @img.export_pixels(0, 0, @img.columns, 1, 'RGB')
    expect do
      res = @img.import_pixels(0, 0, @img.columns, 1, 'RGB', pixels)
      expect(res).to be(@img)
    end.not_to raise_error
    expect { @img.import_pixels }.to raise_error(ArgumentError)
    expect { @img.import_pixels(0) }.to raise_error(ArgumentError)
    expect { @img.import_pixels(0, 0) }.to raise_error(ArgumentError)
    expect { @img.import_pixels(0, 0, @img.columns) }.to raise_error(ArgumentError)
    expect { @img.import_pixels(0, 0, @img.columns, 1) }.to raise_error(ArgumentError)
    expect { @img.import_pixels(0, 0, @img.columns, 1, 'RGB') }.to raise_error(ArgumentError)
    expect { @img.import_pixels('x', 0, @img.columns, 1, 'RGB', pixels) }.to raise_error(TypeError)
    expect { @img.import_pixels(0, 'x', @img.columns, 1, 'RGB', pixels) }.to raise_error(TypeError)
    expect { @img.import_pixels(0, 0, 'x', 1, 'RGB', pixels) }.to raise_error(TypeError)
    expect { @img.import_pixels(0, 0, @img.columns, 'x', 'RGB', pixels) }.to raise_error(TypeError)
    expect { @img.import_pixels(0, 0, @img.columns, 1, [2], pixels) }.to raise_error(TypeError)
    expect { @img.import_pixels(-1, 0, @img.columns, 1, 'RGB', pixels) }.to raise_error(ArgumentError)
    expect { @img.import_pixels(0, -1, @img.columns, 1, 'RGB', pixels) }.to raise_error(ArgumentError)
    expect { @img.import_pixels(0, 0, -1, 1, 'RGB', pixels) }.to raise_error(ArgumentError)
    expect { @img.import_pixels(0, 0, @img.columns, -1, 'RGB', pixels) }.to raise_error(ArgumentError)

    # pixel array is too small
    expect { @img.import_pixels(0, 0, @img.columns, 2, 'RGB', pixels) }.to raise_error(ArgumentError)
    # pixel array doesn't contain a multiple of the map length
    pixels.shift
    expect { @img.import_pixels(0, 0, @img.columns, 1, 'RGB', pixels) }.to raise_error(ArgumentError)
  end
end
