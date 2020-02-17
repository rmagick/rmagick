RSpec.describe Magick::Image, '#edge' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.edge
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    expect { image.edge(2.0) }.not_to raise_error
    expect { image.edge(2.0, 2) }.to raise_error(ArgumentError)
    expect { image.edge('x') }.to raise_error(TypeError)
  end
end
