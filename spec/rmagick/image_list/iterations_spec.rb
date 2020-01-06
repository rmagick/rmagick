RSpec.describe Magick::ImageList, '#iterations' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    expect { list.iterations }.not_to raise_error
    expect(list.iterations).to be_kind_of(Integer)
    expect { list.iterations = 20 }.not_to raise_error
    expect(list.iterations).to eq(20)
    expect { list.iterations = 'x' }.to raise_error(ArgumentError)
  end
end
