RSpec.describe Magick::Image, '#reduce_noise' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.reduce_noise(0)
    expect(result).to be_instance_of(described_class)

    expect { image.reduce_noise(4) }.not_to raise_error
  end
end
