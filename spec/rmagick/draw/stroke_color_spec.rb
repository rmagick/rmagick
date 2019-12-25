RSpec.describe Magick::Draw, '#stroke_color' do
  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    @draw.stroke_color('red')
    expect(@draw.inspect).to eq('stroke "red"')
    @draw.rectangle(10, '10', 100, 100)
    expect { @draw.draw(@img) }.not_to raise_error

    # expect { @draw.stroke_color(100) }.to raise_error(ArgumentError)
  end
end
