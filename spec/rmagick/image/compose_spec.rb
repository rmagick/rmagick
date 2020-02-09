RSpec.describe Magick::Image, '#compose' do
  before do
    @img = described_class.new(100, 100)
    gc = Magick::Draw.new

    gc.stroke_width(5)
    gc.circle(50, 50, 80, 80)
    gc.draw(@img)

    @hat = described_class.read(FLOWER_HAT).first
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect { @img.compose }.not_to raise_error
    expect(@img.compose).to be_instance_of(Magick::CompositeOperator)
    expect(@img.compose).to eq(Magick::OverCompositeOp)
    expect { @img.compose = 2 }.to raise_error(TypeError)
    expect { @img.compose = Magick::UndefinedCompositeOp }.not_to raise_error
    expect(@img.compose).to eq(Magick::UndefinedCompositeOp)

    Magick::CompositeOperator.values do |composite|
      expect { @img.compose = composite }.not_to raise_error
    end
    expect { @img.compose = 2 }.to raise_error(TypeError)
  end
end
