RSpec.describe Magick::Image, '#composite_channel' do
  it 'works' do
    image1 = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    image2 = described_class.read(IMAGES_DIR + '/Button_1.gif').first
    image1.define('compose:args', '1x1')
    image2.define('compose:args', '1x1')
    Magick::CompositeOperator.values do |op|
      Magick::GravityType.values do |gravity|
        res = image1.composite_channel(image2, gravity, 5, 5, op, Magick::BlueChannel)
        expect(res).not_to be(image1)
      end
    end

    expect { image1.composite_channel(image2, Magick::NorthWestGravity) }.to raise_error(ArgumentError)
    expect { image1.composite_channel(image2, Magick::NorthWestGravity, 5, 5, Magick::OverCompositeOp, 'x') }.to raise_error(TypeError)
  end
end
