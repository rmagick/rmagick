RSpec.describe Magick::Image, '#fuzz' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.fuzz }.not_to raise_error
    expect(image.fuzz).to be_instance_of(Float)
    expect(image.fuzz).to eq(0.0)
    expect { image.fuzz = 50 }.not_to raise_error
    expect(image.fuzz).to eq(50.0)
    expect { image.fuzz = '50%' }.not_to raise_error
    expect(image.fuzz).to be_within(0.1).of(Magick::QuantumRange * 0.50)
    expect { image.fuzz = [] }.to raise_error(TypeError)
    expect { image.fuzz = 'xxx' }.to raise_error(ArgumentError)
  end
end
