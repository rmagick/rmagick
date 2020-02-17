RSpec.describe Magick::Image, '#gamma_correct' do
  it 'works' do
    image = described_class.new(20, 20)

    expect { image.gamma_correct }.to raise_error(ArgumentError)

    result = image.gamma_correct(0.8)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.gamma_correct(0.8, 0.9) }.not_to raise_error
    expect { image.gamma_correct(0.8, 0.9, 1.0) }.not_to raise_error
    expect { image.gamma_correct(0.8, 0.9, 1.0, 1.1) }.not_to raise_error
    # too many arguments
    expect { image.gamma_correct(0.8, 0.9, 1.0, 1.1, 2) }.to raise_error(ArgumentError)
  end
end
