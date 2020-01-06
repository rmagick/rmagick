RSpec.describe Magick::Draw, '#text_align' do
  it 'works' do
    draw = described_class.new
    img = Magick::Image.new(200, 200)

    draw.text_align(Magick::LeftAlign)
    expect(draw.inspect).to eq('text-align left')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(img) }.not_to raise_error

    draw = described_class.new
    draw.text_align(Magick::RightAlign)
    expect(draw.inspect).to eq('text-align right')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(img) }.not_to raise_error

    draw = described_class.new
    draw.text_align(Magick::CenterAlign)
    expect(draw.inspect).to eq('text-align center')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(img) }.not_to raise_error

    expect { draw.text_align('x') }.to raise_error(ArgumentError)
  end
end
