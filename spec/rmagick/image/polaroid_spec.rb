RSpec.describe Magick::Image, '#polaroid' do
  it 'works' do
    image = described_class.new(20, 20)

    expect { image.polaroid }.not_to raise_error
    expect { image.polaroid(5) }.not_to raise_error
    expect(image.polaroid).to be_instance_of(described_class)
    expect { image.polaroid('x') }.to raise_error(TypeError)
    expect { image.polaroid(5, 'x') }.to raise_error(ArgumentError)
  end
end
