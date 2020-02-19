RSpec.describe Magick::Draw, '#clip_path' do
  it 'updates the inspect output' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.clip_path('test')
    expect(draw.inspect).to eq('clip-path test')
    expect { draw.draw(image) }.not_to raise_error
  end

  it 'works' do
    points = [0, 0, 1, 1, 2, 2]

    draw = described_class.new

    draw.define_clip_path('example') do
      draw.polygon(*points)
    end

    draw.push
    draw.clip_path('example')

    composite = Magick::Image.new(10, 10)
    draw.composite(0, 0, 10, 10, composite)

    draw.pop

    canvas = Magick::Image.new(10, 10)
    draw.draw(canvas)
  end
end
