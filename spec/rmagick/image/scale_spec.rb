RSpec.describe Magick::Image, '#scale' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.scale(10, 10)
    expect(res).to be_instance_of(described_class)

    expect { img.scale(2) }.not_to raise_error
    expect { img.scale }.to raise_error(ArgumentError)
    expect { img.scale(25, 25, 25) }.to raise_error(ArgumentError)
    expect { img.scale('x') }.to raise_error(TypeError)
    expect { img.scale(10, 'x') }.to raise_error(TypeError)
  end
end
