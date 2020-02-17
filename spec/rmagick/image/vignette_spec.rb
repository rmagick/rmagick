RSpec.describe Magick::Image, '#vignette' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.vignette
    expect(res).to be_instance_of(described_class)
    expect(image).not_to be(res)

    expect { image.vignette(0) }.not_to raise_error
    expect { image.vignette(0, 0) }.not_to raise_error
    expect { image.vignette(0, 0, 0) }.not_to raise_error
    expect { image.vignette(0, 0, 0, 1) }.not_to raise_error
    # too many arguments
    expect { image.vignette(0, 0, 0, 1, 1) }.to raise_error(ArgumentError)
  end
end
