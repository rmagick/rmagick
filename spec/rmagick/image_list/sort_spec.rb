RSpec.describe Magick::ImageList, '#sort' do
  before do
    @list = described_class.new(*FILES[0..9])
  end

  it 'works' do
    expect { @list.sort }.not_to raise_error
    expect { @list.sort! }.not_to raise_error
  end
end
