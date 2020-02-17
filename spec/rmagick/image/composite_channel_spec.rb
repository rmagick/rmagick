RSpec.describe Magick::Image, '#composite_channel' do
  it 'works' do
    img1 = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    img2 = described_class.read(IMAGES_DIR + '/Button_1.gif').first
    img1.define('compose:args', '1x1')
    img2.define('compose:args', '1x1')
    Magick::CompositeOperator.values do |op|
      Magick::GravityType.values do |gravity|
        res = img1.composite_channel(img2, gravity, 5, 5, op, Magick::BlueChannel)
        expect(res).not_to be(img1)
      end
    end

    expect { img1.composite_channel(img2, Magick::NorthWestGravity) }.to raise_error(ArgumentError)
    expect { img1.composite_channel(img2, Magick::NorthWestGravity, 5, 5, Magick::OverCompositeOp, 'x') }.to raise_error(TypeError)
  end
end
