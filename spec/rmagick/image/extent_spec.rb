RSpec.describe Magick::Image, '#extent' do
  it 'works' do
    img = described_class.new(20, 20)

    expect { img.extent(40, 40) }.not_to raise_error
    res = img.extent(40, 40)
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(img)
    expect(res.columns).to eq(40)
    expect(res.rows).to eq(40)
    expect { img.extent(40, 40, 5) }.not_to raise_error
    expect { img.extent(40, 40, 5, 5) }.not_to raise_error
    expect { img.extent(-40) }.to raise_error(ArgumentError)
    expect { img.extent(-40, 40) }.to raise_error(ArgumentError)
    expect { img.extent(40, -40) }.to raise_error(ArgumentError)
    expect { img.extent(40, 40, 5, 5, 0) }.to raise_error(ArgumentError)
    expect { img.extent(0, 0, 5, 5) }.to raise_error(ArgumentError)
    expect { img.extent('x', 40) }.to raise_error(TypeError)
    expect { img.extent(40, 'x') }.to raise_error(TypeError)
    expect { img.extent(40, 40, 'x') }.to raise_error(TypeError)
    expect { img.extent(40, 40, 5, 'x') }.to raise_error(TypeError)
  end
end
