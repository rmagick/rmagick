RSpec.describe Magick::ImageList, '#sort' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    expect { image_list.sort }.not_to raise_error
    expect { image_list.sort! }.not_to raise_error
  end
end
