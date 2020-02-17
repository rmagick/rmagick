RSpec.describe Magick::Image, '#spread' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.spread
    expect(result).to be_instance_of(described_class)

    expect { image.spread(3.0) }.not_to raise_error
    expect { image.spread(3.0, 2) }.to raise_error(ArgumentError)
    expect { image.spread('x') }.to raise_error(TypeError)
  end
end
