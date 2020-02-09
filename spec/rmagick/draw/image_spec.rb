RSpec.describe Magick::Draw, '#image' do
  before do
    @draw = described_class.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    Magick::CompositeOperator.values do |composite|
      next if [Magick::BlurCompositeOp, Magick::CopyAlphaCompositeOp, Magick::NoCompositeOp].include?(composite)

      draw = described_class.new
      draw.image(composite, 10, 10, 200, 100, "#{IMAGES_DIR}/Flower_Hat.jpg")
      expect { draw.draw(@img) }.not_to raise_error
    end

    expect { @draw.image('xxx', 10, 10, 200, 100, "#{IMAGES_DIR}/Flower_Hat.jpg") }.to raise_error(ArgumentError)
    expect { @draw.image(Magick::AtopCompositeOp, 'x', 100, 200, 100, "#{IMAGES_DIR}/Flower_Hat.jpg") }.to raise_error(ArgumentError)
    expect { @draw.image(Magick::AtopCompositeOp, 100, 'x', 200, 100, "#{IMAGES_DIR}/Flower_Hat.jpg") }.to raise_error(ArgumentError)
    expect { @draw.image(Magick::AtopCompositeOp, 100, 100, 'x', 100, "#{IMAGES_DIR}/Flower_Hat.jpg") }.to raise_error(ArgumentError)
    expect { @draw.image(Magick::AtopCompositeOp, 100, 100, 200, 'x', "#{IMAGES_DIR}/Flower_Hat.jpg") }.to raise_error(ArgumentError)
  end
end
