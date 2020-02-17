RSpec.describe Magick::Draw, '#clip_path' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.clip_path('test')
    expect(draw.inspect).to eq('clip-path test')
    expect { draw.draw(image) }.not_to raise_error
  end

  it 'works' do
    points = [0, 0, 1, 1, 2, 2]

    pr = described_class.new

    pr.define_clip_path('example') do
      pr.polygon(*points)
    end

    pr.push
    pr.clip_path('example')

    composite = Magick::Image.new(10, 10)
    pr.composite(0, 0, 10, 10, composite)

    pr.pop

    canvas = Magick::Image.new(10, 10)
    pr.draw(canvas)
  end
end
