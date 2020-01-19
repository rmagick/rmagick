RSpec.describe Magick::ImageList, '#delay' do
  before do
    @list = described_class.new(*FILES[0..9])
  end

  it 'works' do
    expect { @list.delay }.not_to raise_error
    expect(@list.delay).to eq(0)
    expect { @list.delay = 20 }.not_to raise_error
    expect(@list.delay).to eq(20)
    expect { @list.delay = 'x' }.to raise_error(ArgumentError)
  end
end
