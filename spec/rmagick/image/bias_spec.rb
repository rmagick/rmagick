RSpec.describe Magick::Image, '#bias' do
  before do
    @img = Magick::Image.new(100, 100)
    gc = Magick::Draw.new

    gc.stroke_width(5)
    gc.circle(50, 50, 80, 80)
    gc.draw(@img)

    @hat = Magick::Image.read(FLOWER_HAT).first
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect { @img.bias }.not_to raise_error
    expect(@img.bias).to eq(0.0)
    expect(@img.bias).to be_instance_of(Float)

    expect { @img.bias = 0.1 }.not_to raise_error
    expect(@img.bias).to be_within(0.1).of(Magick::QuantumRange * 0.1)

    expect { @img.bias = '10%' }.not_to raise_error
    expect(@img.bias).to be_within(0.1).of(Magick::QuantumRange * 0.10)

    expect { @img.bias = [] }.to raise_error(TypeError)
    expect { @img.bias = 'x' }.to raise_error(ArgumentError)
  end
end
