RSpec.describe Magick::ImageList, '#sort' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    expect { list.sort }.not_to raise_error
    expect { list.sort! }.not_to raise_error
  end
end
