RSpec.describe Magick::Draw, '#clip_rule' do
  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    draw = Magick::Draw.new
    draw.clip_rule('evenodd')
    expect(draw.inspect).to eq('clip-rule evenodd')
    expect { draw.draw(@img) }.not_to raise_error

    draw = Magick::Draw.new
    draw.clip_rule('nonzero')
    expect(draw.inspect).to eq('clip-rule nonzero')
    expect { draw.draw(@img) }.not_to raise_error

    expect { @draw.clip_rule('foo') }.to raise_error(ArgumentError)
  end
end
