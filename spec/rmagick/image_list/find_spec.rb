RSpec.describe Magick::ImageList, '#find' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    expect { list.find { true } }.not_to raise_error
  end
end
