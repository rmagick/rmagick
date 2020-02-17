RSpec.describe Magick::Image, '#gamma' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.gamma }.not_to raise_error
    expect(image.gamma).to be_instance_of(Float)
    expect(image.gamma).to eq(0.45454543828964233)
    expect { image.gamma = 2.0 }.not_to raise_error
    expect(image.gamma).to eq(2.0)
    expect { image.gamma = 'x' }.to raise_error(TypeError)
  end
end
