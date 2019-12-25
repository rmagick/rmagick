RSpec.describe Magick::Draw, '#font_stretch' do
  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    Magick::StretchType.values do |stretch|
      next if stretch == Magick::AnyStretch

      draw = Magick::Draw.new
      draw.font_stretch(stretch)
      draw.text(50, 50, 'Hello world')
      expect { draw.draw(@img) }.not_to raise_error
    end

    expect { @draw.font_stretch('xxx') }.to raise_error(ArgumentError)
  end
end
