RSpec.describe Magick::Draw, '#interline_spacing' do
  let(:draw) { described_class.new }

  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'accepts a valid parameter without raising an error' do
    expect { draw.interline_spacing(1) }.not_to raise_error
  end

  it 'raises an error when given an invalid parameter' do
    expect { draw.interline_spacing('a') }.to raise_error(ArgumentError)
    expect { draw.interline_spacing([]) }.to raise_error(TypeError)
  end

  it 'works' do
    draw = Magick::Draw.new
    draw.interline_spacing(40.5)
    expect(draw.inspect).to eq('interline-spacing 40.5')
    expect { draw.draw(@img) }.not_to raise_error

    draw = Magick::Draw.new
    draw.interline_spacing('40.5')
    expect(draw.inspect).to eq('interline-spacing 40.5')
    expect { draw.draw(@img) }.not_to raise_error

    # expect { @draw.interline_spacing(Float::NAN) }.to raise_error(ArgumentError)
    expect { @draw.interline_spacing('nan') }.to raise_error(ArgumentError)
    expect { @draw.interline_spacing('xxx') }.to raise_error(ArgumentError)
    expect { @draw.interline_spacing(nil) }.to raise_error(TypeError)
  end
end
