RSpec.describe Magick::Image, '#posterize' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.posterize
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    expect { image.posterize(5) }.not_to raise_error
    expect { image.posterize(5, true) }.not_to raise_error
    expect { image.posterize(5, true, 'x') }.to raise_error(ArgumentError)
  end
end
