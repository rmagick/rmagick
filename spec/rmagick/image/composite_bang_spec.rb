RSpec.describe Magick::Image, '#composite!' do
  it 'works' do
    image1 = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    image2 = described_class.read(IMAGES_DIR + '/Button_1.gif').first
    image1.define('compose:args', '1x1')
    image2.define('compose:args', '1x1')
    Magick::CompositeOperator.values do |op|
      Magick::GravityType.values do |gravity|
        result = image1.composite!(image2, gravity, op)
        expect(result).to be(image1)
      end
    end
    image1.freeze
    expect { image1.composite!(image2, Magick::NorthWestGravity, Magick::OverCompositeOp) }.to raise_error(FreezeError)
  end

  it 'accepts an ImageList argument' do
    image = described_class.new(20, 20)

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    expect { image.composite!(image_list, Magick::NorthWestGravity, Magick::OverCompositeOp) }.not_to raise_error
  end
end
