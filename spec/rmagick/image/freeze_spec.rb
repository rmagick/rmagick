# frozen_string_literal: true

RSpec.describe Magick::Image, '#freeze' do
  it 'works' do
    image = described_class.new(100, 100)

    image.freeze

    expect { image.background_color = 'xxx' }.to raise_error(FrozenError)
    expect { image.border_color = 'xxx' }.to raise_error(FrozenError)
    rp = Magick::Point.new(1, 1)
    gp = Magick::Point.new(1, 1)
    bp = Magick::Point.new(1, 1)
    wp = Magick::Point.new(1, 1)
    expect { image.chromaticity = Magick::Chromaticity.new(rp, gp, bp, wp) }.to raise_error(FrozenError)
    expect { image.class_type = Magick::DirectClass }.to raise_error(FrozenError)
    expect { image.color_profile = 'xxx' }.to raise_error(FrozenError)
    expect { image.colorspace = Magick::RGBColorspace }.to raise_error(FrozenError)
    expect { image.compose = Magick::OverCompositeOp }.to raise_error(FrozenError)
    expect { image.compression = Magick::RLECompression }.to raise_error(FrozenError)
    expect { image.delay = 2 }.to raise_error(FrozenError)
    expect { image.density = '72.0x72.0' }.to raise_error(FrozenError)
    expect { image.dispose = Magick::NoneDispose }.to raise_error(FrozenError)
    expect { image.endian = Magick::MSBEndian }.to raise_error(FrozenError)
    expect { image.extract_info = Magick::Rectangle.new(1, 2, 3, 4) }.to raise_error(FrozenError)
    expect { image.filter = Magick::PointFilter }.to raise_error(FrozenError)
    expect { image.format = 'GIF' }.to raise_error(FrozenError)
    expect { image.fuzz = 50.0 }.to raise_error(FrozenError)
    expect { image.gamma = 2.0 }.to raise_error(FrozenError)
    expect { image.geometry = '100x100' }.to raise_error(FrozenError)
    expect { image.interlace = Magick::NoInterlace }.to raise_error(FrozenError)
    expect { image.iptc_profile = 'xxx' }.to raise_error(FrozenError)
    expect { image.offset = 100 }.to raise_error(FrozenError)
    expect { image.page = Magick::Rectangle.new(1, 2, 3, 4) }.to raise_error(FrozenError)
    expect { image.rendering_intent = Magick::SaturationIntent }.to raise_error(FrozenError)
    expect { image.start_loop = true }.to raise_error(FrozenError)
    expect { image.ticks_per_second = 1000 }.to raise_error(FrozenError)
    expect { image.units = Magick::PixelsPerInchResolution }.to raise_error(FrozenError)
    expect { image.x_resolution = 72.0 }.to raise_error(FrozenError)
    expect { image.y_resolution = 72.0 }.to raise_error(FrozenError)
  end
end
