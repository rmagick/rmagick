RSpec.describe Magick::ImageList, '#map!' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image = image_list[0]
    expect do
      image_list.map! { image }
    end.not_to raise_error
    expect(image_list).to be_instance_of(described_class)
    expect { image_list.map! { 2 } }.to raise_error(ArgumentError)
  end
end
