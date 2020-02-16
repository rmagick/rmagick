RSpec.describe Magick::ImageList, '#delay' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    expect { list.delay }.not_to raise_error
    expect(list.delay).to eq(0)
    expect { list.delay = 20 }.not_to raise_error
    expect(list.delay).to eq(20)
    expect { list.delay = 'x' }.to raise_error(ArgumentError)
  end
end
