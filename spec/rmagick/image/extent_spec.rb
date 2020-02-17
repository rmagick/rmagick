RSpec.describe Magick::Image, '#extent' do
  it 'works' do
    image = described_class.new(20, 20)

    expect { image.extent(40, 40) }.not_to raise_error
    result = image.extent(40, 40)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)
    expect(result.columns).to eq(40)
    expect(result.rows).to eq(40)
    expect { image.extent(40, 40, 5) }.not_to raise_error
    expect { image.extent(40, 40, 5, 5) }.not_to raise_error
    expect { image.extent(-40) }.to raise_error(ArgumentError)
    expect { image.extent(-40, 40) }.to raise_error(ArgumentError)
    expect { image.extent(40, -40) }.to raise_error(ArgumentError)
    expect { image.extent(40, 40, 5, 5, 0) }.to raise_error(ArgumentError)
    expect { image.extent(0, 0, 5, 5) }.to raise_error(ArgumentError)
    expect { image.extent('x', 40) }.to raise_error(TypeError)
    expect { image.extent(40, 'x') }.to raise_error(TypeError)
    expect { image.extent(40, 40, 'x') }.to raise_error(TypeError)
    expect { image.extent(40, 40, 5, 'x') }.to raise_error(TypeError)
  end
end
