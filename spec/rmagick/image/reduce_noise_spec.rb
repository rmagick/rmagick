RSpec.describe Magick::Image, '#reduce_noise' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.reduce_noise(0)
    expect(res).to be_instance_of(described_class)

    expect { image.reduce_noise(4) }.not_to raise_error
  end
end
