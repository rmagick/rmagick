RSpec.describe Magick::Image, '#composite!' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    img1 = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    img2 = described_class.read(IMAGES_DIR + '/Button_1.gif').first
    img1.define('compose:args', '1x1')
    img2.define('compose:args', '1x1')
    Magick::CompositeOperator.values do |op|
      Magick::GravityType.values do |gravity|
        expect do
          res = img1.composite!(img2, gravity, op)
          expect(res).to be(img1)
        end.not_to raise_error
      end
    end
    img1.freeze
    expect { img1.composite!(img2, Magick::NorthWestGravity, Magick::OverCompositeOp) }.to raise_error(FreezeError)
  end
end
