RSpec.describe Magick::Image, '#shade' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.shade
    expect(res).to be_instance_of(described_class)

    expect { image.shade(true) }.not_to raise_error
    expect { image.shade(true, 30) }.not_to raise_error
    expect { image.shade(true, 30, 30) }.not_to raise_error
    expect { image.shade(true, 30, 30, 2) }.to raise_error(ArgumentError)
    expect { image.shade(true, 'x') }.to raise_error(TypeError)
    expect { image.shade(true, 30, 'x') }.to raise_error(TypeError)
  end
end
