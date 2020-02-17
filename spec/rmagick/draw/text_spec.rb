RSpec.describe Magick::Draw, '#text' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.text(50, 50, 'Hello world')
    expect(draw.inspect).to eq("text 50,50 'Hello world'")
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.text(50, 50, "Hello 'world'")
    expect(draw.inspect).to eq("text 50,50 \"Hello 'world'\"")
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.text(50, 50, 'Hello "world"')
    expect(draw.inspect).to eq("text 50,50 'Hello \"world\"'")
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.text(50, 50, "Hello 'world\"")
    expect(draw.inspect).to eq("text 50,50 {Hello 'world\"}")
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.text(50, 50, "Hello {'world\"")
    expect(draw.inspect).to eq("text 50,50 {Hello {'world\"}")
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.text(50, 50, '') }.to raise_error(ArgumentError)
    expect { draw.text('x', 50, 'Hello world') }.to raise_error(ArgumentError)
    expect { draw.text(50, 'x', 'Hello world') }.to raise_error(ArgumentError)
  end
end
