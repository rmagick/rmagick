RSpec.describe Magick::Draw, '#kerning' do
  let(:draw) { described_class.new }

  it 'accepts a valid parameter without raising an error' do
    expect { draw.kerning(1) }.not_to raise_error
  end

  it 'raises an error when given an invalid parameter' do
    expect { draw.kerning('a') }.to raise_error(ArgumentError)
    expect { draw.kerning([]) }.to raise_error(TypeError)
  end
end
