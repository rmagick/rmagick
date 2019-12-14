RSpec.describe Magick::Draw, '#interword_spacing=' do
  let(:draw) { described_class.new }

  it 'assigns without raising an error' do
    expect { draw.interword_spacing = 1 }.not_to raise_error
  end
end
