RSpec.describe Magick::ImageList, '#combine' do
  it 'works' do
    red   = Magick::Image.new(20, 20) { self.background_color = 'red' }
    green = Magick::Image.new(20, 20) { self.background_color = 'green' }
    blue  = Magick::Image.new(20, 20) { self.background_color = 'blue' }
    black = Magick::Image.new(20, 20) { self.background_color = 'black' }
    alpha = Magick::Image.new(20, 20) { self.background_color = 'transparent' }

    list = Magick::ImageList.new
    expect { list.combine }.to raise_error(ArgumentError)

    list << red
    expect { list.combine }.not_to raise_error

    res = list.combine
    expect(res).to be_instance_of(Magick::Image)

    list << alpha
    expect { list.combine }.not_to raise_error

    list.pop
    list << green
    list << blue
    expect { list.combine }.not_to raise_error

    list << alpha
    expect { list.combine }.not_to raise_error

    list.pop
    list << black
    expect { list.combine(Magick::CMYKColorspace) }.not_to raise_error
    expect { list.combine(Magick::SRGBColorspace) }.not_to raise_error

    list << alpha
    expect { list.combine(Magick::CMYKColorspace) }.not_to raise_error
    expect { list.combine(Magick::SRGBColorspace) }.to raise_error(ArgumentError)

    list << alpha
    expect { list.combine }.to raise_error(ArgumentError)

    expect { list.combine(nil) }.to raise_error(TypeError)
    expect { list.combine(Magick::SRGBColorspace, 1) }.to raise_error(ArgumentError)
  end
end
