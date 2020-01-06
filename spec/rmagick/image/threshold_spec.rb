RSpec.describe Magick::Image, '#threshold' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.threshold(100)
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error
  end
end
