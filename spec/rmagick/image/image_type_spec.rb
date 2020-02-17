RSpec.describe Magick::Image, '#image_type' do
  it 'works' do
    image = described_class.new(100, 100)

    expect(image.image_type).to be_instance_of(Magick::ImageType)

    Magick::ImageType.values do |image_type|
      expect { image.image_type = image_type }.not_to raise_error
    end
    expect { image.image_type = nil }.to raise_error(TypeError)
    expect { image.image_type = Magick::PointFilter }.to raise_error(TypeError)
  end
end
