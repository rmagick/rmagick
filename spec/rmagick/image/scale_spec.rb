RSpec.describe Magick::Image, '#scale' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.scale(10, 10)
    expect(res).to be_instance_of(described_class)

    expect { image.scale(2) }.not_to raise_error
    expect { image.scale }.to raise_error(ArgumentError)
    expect { image.scale(25, 25, 25) }.to raise_error(ArgumentError)
    expect { image.scale('x') }.to raise_error(TypeError)
    expect { image.scale(10, 'x') }.to raise_error(TypeError)
  end
end
