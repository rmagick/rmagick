RSpec.describe Magick::Image, '#negate' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.negate
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    expect { image.negate(true) }.not_to raise_error
    expect { image.negate(true, 2) }.to raise_error(ArgumentError)
  end
end
