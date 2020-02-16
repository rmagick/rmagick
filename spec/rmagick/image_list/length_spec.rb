RSpec.describe Magick::ImageList, '#length' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    expect { list.length }.not_to raise_error
    expect(list.length).to eq(10)
    expect { list.length = 2 }.to raise_error(NoMethodError)
  end
end
