RSpec.describe Magick::Image, '#image_type' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect(@img.image_type).to be_instance_of(Magick::ImageType)

    Magick::ImageType.values do |image_type|
      expect { @img.image_type = image_type }.not_to raise_error
    end
    expect { @img.image_type = nil }.to raise_error(TypeError)
    expect { @img.image_type = Magick::PointFilter }.to raise_error(TypeError)
  end
end
