RSpec.describe Magick::Draw, '#stroke_opacity' do
  it 'works' do
    draw = described_class.new
    img = Magick::Image.new(200, 200)

    draw.stroke_opacity(0.8)
    expect(draw.inspect).to eq('stroke-opacity 0.8')
    expect { draw.draw(img) }.not_to raise_error

    expect { draw.stroke_opacity(0.0) }.not_to raise_error
    expect { draw.stroke_opacity(1.0) }.not_to raise_error
    expect { draw.stroke_opacity('0.0') }.not_to raise_error
    expect { draw.stroke_opacity('1.0') }.not_to raise_error
    expect { draw.stroke_opacity('20%') }.not_to raise_error

    expect { draw.stroke_opacity(-0.01) }.to raise_error(ArgumentError)
    expect { draw.stroke_opacity(1.01) }.to raise_error(ArgumentError)
    expect { draw.stroke_opacity('-0.01') }.to raise_error(ArgumentError)
    expect { draw.stroke_opacity('1.01') }.to raise_error(ArgumentError)
    expect { draw.stroke_opacity('xxx') }.to raise_error(ArgumentError)
  end
end
