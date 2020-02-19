RSpec.describe Magick::ImageList, '#<<' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])
    image_list2 = described_class.new # intersection is 5..9
    image_list2 << image_list[5]
    image_list2 << image_list[6]
    image_list2 << image_list[7]
    image_list2 << image_list[8]
    image_list2 << image_list[9]

    image_list2.each { |image| image_list << image }
    expect(image_list.length).to eq(15)
    expect(image_list.scene).to eq(14)

    expect { image_list << 2 }.to raise_error(ArgumentError)
    expect { image_list << [2] }.to raise_error(ArgumentError)
  end
end
