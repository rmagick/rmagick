RSpec.describe Magick::Image, '#edge' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.edge
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(img)

    expect { img.edge(2.0) }.not_to raise_error
    expect { img.edge(2.0, 2) }.to raise_error(ArgumentError)
    expect { img.edge('x') }.to raise_error(TypeError)
  end
end
