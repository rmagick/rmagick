RSpec.describe Magick::ImageList, '#iterations' do
  before do
    @list = described_class.new(*FILES[0..9])
  end

  it 'works' do
    expect { @list.iterations }.not_to raise_error
    expect(@list.iterations).to be_kind_of(Integer)
    expect { @list.iterations = 20 }.not_to raise_error
    expect(@list.iterations).to eq(20)
    expect { @list.iterations = 'x' }.to raise_error(ArgumentError)
  end
end
