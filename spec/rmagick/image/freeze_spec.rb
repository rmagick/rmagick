RSpec.describe Magick::Image, '#freeze' do
  before do
    @img = described_class.new(100, 100)
    gc = Magick::Draw.new

    gc.stroke_width(5)
    gc.circle(50, 50, 80, 80)
    gc.draw(@img)

    @hat = described_class.read(FLOWER_HAT).first
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    @img.freeze
    expect { @img.background_color = 'xxx' }.to raise_error(FreezeError)
    expect { @img.border_color = 'xxx' }.to raise_error(FreezeError)
    rp = Magick::Point.new(1, 1)
    gp = Magick::Point.new(1, 1)
    bp = Magick::Point.new(1, 1)
    wp = Magick::Point.new(1, 1)
    expect { @img.chromaticity = Magick::Chromaticity.new(rp, gp, bp, wp) }.to raise_error(FreezeError)
    expect { @img.class_type = Magick::DirectClass }.to raise_error(FreezeError)
    expect { @img.color_profile = 'xxx' }.to raise_error(FreezeError)
    expect { @img.colorspace = Magick::RGBColorspace }.to raise_error(FreezeError)
    expect { @img.compose = Magick::OverCompositeOp }.to raise_error(FreezeError)
    expect { @img.compression = Magick::RLECompression }.to raise_error(FreezeError)
    expect { @img.delay = 2 }.to raise_error(FreezeError)
    expect { @img.density = '72.0x72.0' }.to raise_error(FreezeError)
    expect { @img.dispose = Magick::NoneDispose }.to raise_error(FreezeError)
    expect { @img.endian = Magick::MSBEndian }.to raise_error(FreezeError)
    expect { @img.extract_info = Magick::Rectangle.new(1, 2, 3, 4) }.to raise_error(FreezeError)
    expect { @img.filter = Magick::PointFilter }.to raise_error(FreezeError)
    expect { @img.format = 'GIF' }.to raise_error(FreezeError)
    expect { @img.fuzz = 50.0 }.to raise_error(FreezeError)
    expect { @img.gamma = 2.0 }.to raise_error(FreezeError)
    expect { @img.geometry = '100x100' }.to raise_error(FreezeError)
    expect { @img.interlace = Magick::NoInterlace }.to raise_error(FreezeError)
    expect { @img.iptc_profile = 'xxx' }.to raise_error(FreezeError)
    expect { @img.monitor = proc { |name, _q, _s| puts name } }.to raise_error(FreezeError)
    expect { @img.offset = 100 }.to raise_error(FreezeError)
    expect { @img.page = Magick::Rectangle.new(1, 2, 3, 4) }.to raise_error(FreezeError)
    expect { @img.rendering_intent = Magick::SaturationIntent }.to raise_error(FreezeError)
    expect { @img.start_loop = true }.to raise_error(FreezeError)
    expect { @img.ticks_per_second = 1000 }.to raise_error(FreezeError)
    expect { @img.units = Magick::PixelsPerInchResolution }.to raise_error(FreezeError)
    expect { @img.x_resolution = 72.0 }.to raise_error(FreezeError)
    expect { @img.y_resolution = 72.0 }.to raise_error(FreezeError)
  end
end
