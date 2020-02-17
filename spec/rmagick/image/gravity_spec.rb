RSpec.describe Magick::Image, '#gravity' do
  it 'works' do
    image = described_class.new(100, 100)

    expect(image.gravity).to be_instance_of(Magick::GravityType)

    Magick::GravityType.values do |gravity|
      expect { image.gravity = gravity }.not_to raise_error
    end
    expect { image.gravity = nil }.to raise_error(TypeError)
    expect { image.gravity = Magick::PointFilter }.to raise_error(TypeError)
  end
end
