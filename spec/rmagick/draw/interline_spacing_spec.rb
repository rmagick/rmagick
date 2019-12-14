RSpec.describe Magick::Draw, '#interline_spacing' do
  let(:draw) { described_class.new }

  it 'accepts a valid parameter without raising an error' do
    expect { draw.interline_spacing(1) }.not_to raise_error
  end

  it 'raises an error when given an invalid parameter' do
    expect { draw.interline_spacing('a') }.to raise_error(ArgumentError)
    expect { draw.interline_spacing([]) }.to raise_error(TypeError)
  end
end
