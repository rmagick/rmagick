RSpec.describe Magick::Draw, '#kerning=' do
  let(:draw) { described_class.new }

  it 'assigns without raising an error' do
    expect { draw.kerning = 1 }.not_to raise_error
  end
end
