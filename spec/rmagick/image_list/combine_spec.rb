RSpec.describe Magick::ImageList, '#combine' do
  it 'works' do
    red   = Magick::Image.new(20, 20) { self.background_color = 'red' }
    green = Magick::Image.new(20, 20) { self.background_color = 'green' }
    blue  = Magick::Image.new(20, 20) { self.background_color = 'blue' }
    black = Magick::Image.new(20, 20) { self.background_color = 'black' }
    alpha = Magick::Image.new(20, 20) { self.background_color = 'transparent' }

    image_list = described_class.new
    expect { image_list.combine }.to raise_error(ArgumentError)

    image_list << red
    expect { image_list.combine }.not_to raise_error

    result = image_list.combine
    expect(result).to be_instance_of(Magick::Image)

    image_list << alpha
    expect { image_list.combine }.not_to raise_error

    image_list.pop
    image_list << green
    image_list << blue
    expect { image_list.combine }.not_to raise_error

    image_list << alpha
    expect { image_list.combine }.not_to raise_error

    image_list.pop
    image_list << black
    expect { image_list.combine(Magick::CMYKColorspace) }.not_to raise_error
    expect { image_list.combine(Magick::SRGBColorspace) }.not_to raise_error

    image_list << alpha
    expect { image_list.combine(Magick::CMYKColorspace) }.not_to raise_error
    expect { image_list.combine(Magick::SRGBColorspace) }.to raise_error(ArgumentError)

    image_list << alpha
    expect { image_list.combine }.to raise_error(ArgumentError)

    expect { image_list.combine(nil) }.to raise_error(TypeError)
    expect { image_list.combine(Magick::SRGBColorspace, 1) }.to raise_error(ArgumentError)
  end
end
