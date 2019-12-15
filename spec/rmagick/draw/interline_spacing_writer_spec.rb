RSpec.describe Magick::Draw, '#interline_spacing=' do
  let(:draw) { described_class.new }

  it 'assigns without raising an error' do
    expect { draw.interline_spacing = 1 }.not_to raise_error
  end
end
