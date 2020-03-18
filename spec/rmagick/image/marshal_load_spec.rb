RSpec.describe Magick::Image, '#marshal_load' do
  it 'works' do
    image1 = described_class.read('granite:').first
    image2 = described_class.new(10, 10)
    expect { image2.marshal_load(image1.marshal_dump) }.not_to raise_error
    expect { image2.marshal_load([1234, 5678]) }.to raise_error(TypeError)
  end
end
