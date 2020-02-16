RSpec.describe Magick::Image, '#gamma' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.gamma }.not_to raise_error
    expect(img.gamma).to be_instance_of(Float)
    expect(img.gamma).to eq(0.45454543828964233)
    expect { img.gamma = 2.0 }.not_to raise_error
    expect(img.gamma).to eq(2.0)
    expect { img.gamma = 'x' }.to raise_error(TypeError)
  end
end
