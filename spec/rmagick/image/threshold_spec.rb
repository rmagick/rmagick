RSpec.describe Magick::Image, '#threshold' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.threshold(100)
    expect(res).to be_instance_of(described_class)
  end
end
