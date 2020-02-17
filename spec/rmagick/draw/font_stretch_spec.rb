RSpec.describe Magick::Draw, '#font_stretch' do
  it 'works' do
    draw1 = described_class.new
    image = Magick::Image.new(200, 200)

    Magick::StretchType.values do |stretch|
      next if stretch == Magick::AnyStretch

      draw2 = described_class.new
      draw2.font_stretch(stretch)
      draw2.text(50, 50, 'Hello world')
      expect { draw2.draw(image) }.not_to raise_error
    end

    expect { draw1.font_stretch('xxx') }.to raise_error(ArgumentError)
  end
end
