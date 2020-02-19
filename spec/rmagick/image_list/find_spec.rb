RSpec.describe Magick::ImageList, '#find' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    expect { image_list.find { true } }.not_to raise_error
  end
end
