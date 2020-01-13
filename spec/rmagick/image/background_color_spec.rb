RSpec.describe Magick::Image, '#background_color' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.background_color }.not_to raise_error
    expect(@img.background_color).to eq('white')
    expect { @img.background_color = '#dfdfdf' }.not_to raise_error
    # expect(@img.background_color).to eq("rgb(223,223,223)")
    background_color = @img.background_color
    if background_color.length == 13
      expect(background_color).to eq('#DFDFDFDFDFDF')
    else
      expect(background_color).to eq('#DFDFDFDFDFDFFFFF')
    end
    expect { @img.background_color = Magick::Pixel.new(Magick::QuantumRange, Magick::QuantumRange / 2.0, Magick::QuantumRange / 2.0) }.not_to raise_error
    # expect(@img.background_color).to eq("rgb(100%,49.9992%,49.9992%)")
    background_color = @img.background_color
    if background_color.length == 13
      expect(background_color).to eq('#FFFF7FFF7FFF')
    else
      expect(background_color).to eq('#FFFF7FFF7FFFFFFF')
    end
    expect { @img.background_color = 2 }.to raise_error(TypeError)
  end
end
