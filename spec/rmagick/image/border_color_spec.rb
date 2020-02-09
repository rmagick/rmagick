RSpec.describe Magick::Image, '#border_color' do
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
    expect { @img.border_color }.not_to raise_error
    # expect(@img.border_color).to eq("rgb(223,223,223)")
    border_color = @img.border_color
    if border_color.length == 13
      expect(border_color).to eq('#DFDFDFDFDFDF')
    else
      expect(border_color).to eq('#DFDFDFDFDFDFFFFF')
    end
    expect { @img.border_color = 'red' }.not_to raise_error
    expect(@img.border_color).to eq('red')
    expect { @img.border_color = Magick::Pixel.new(Magick::QuantumRange, Magick::QuantumRange / 2, Magick::QuantumRange / 2) }.not_to raise_error
    # expect(@img.border_color).to eq("rgb(100%,49.9992%,49.9992%)")
    border_color = @img.border_color
    if border_color.length == 13
      expect(border_color).to eq('#FFFF7FFF7FFF')
    else
      expect(border_color).to eq('#FFFF7FFF7FFFFFFF')
    end
    expect { @img.border_color = 2 }.to raise_error(TypeError)
  end
end
