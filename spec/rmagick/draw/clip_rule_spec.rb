RSpec.describe Magick::Draw, '#clip_rule' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.clip_rule('evenodd')
    expect(draw.inspect).to eq('clip-rule evenodd')
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.clip_rule('nonzero')
    expect(draw.inspect).to eq('clip-rule nonzero')
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.clip_rule('foo') }.to raise_error(ArgumentError)
  end
end
