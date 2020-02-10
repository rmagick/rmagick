RSpec.describe Magick::ImageList, '#find' do
  before do
    @list = described_class.new(*FILES[0..9])
  end

  it 'works' do
    expect { @list.find { true } }.not_to raise_error
  end
end
