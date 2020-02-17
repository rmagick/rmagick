RSpec.describe Magick::ImageList, '#__map__' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])
    image = image_list[0]

    expect do
      image_list.__map__ { |_x| image }
    end.not_to raise_error
    expect(image_list).to be_instance_of(described_class)
    expect { image_list.__map__ { 2 } }.to raise_error(ArgumentError)
  end
end
