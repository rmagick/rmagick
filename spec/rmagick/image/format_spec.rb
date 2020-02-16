RSpec.describe Magick::Image, '#format' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.format }.not_to raise_error
    expect(img.format).to be(nil)
    expect { img.format = 'GIF' }.not_to raise_error
    expect { img.format = 'JPG' }.not_to raise_error
    expect { img.format = 'TIFF' }.not_to raise_error
    expect { img.format = 'MIFF' }.not_to raise_error
    expect { img.format = 'MPEG' }.not_to raise_error
    v = $VERBOSE
    $VERBOSE = nil
    expect { img.format = 'shit' }.to raise_error(ArgumentError)
    $VERBOSE = v
    expect { img.format = 2 }.to raise_error(TypeError)
  end
end
