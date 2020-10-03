RSpec.describe Magick::Image, '#format' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.format }.not_to raise_error
    expect(image.format).to be(nil)
    expect { image.format = 'GIF' }.not_to raise_error
    expect { image.format = 'JPG' }.not_to raise_error
    expect { image.format = 'TIFF' }.not_to raise_error
    expect { image.format = 'MIFF' }.not_to raise_error
    v = $VERBOSE
    $VERBOSE = nil
    expect { image.format = 'shit' }.to raise_error(ArgumentError)
    $VERBOSE = v
    expect { image.format = 2 }.to raise_error(TypeError)
  end
end
