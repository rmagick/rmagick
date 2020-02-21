# rubocop:disable Style/CollectionMethods
RSpec.describe Magick::ImageList, '#find_all' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    result = image_list.find_all { |image| File.basename(image.filename) =~ /Button_2/ }
    expect(result).to be_instance_of(described_class)
    expect(result.length).to eq(1)
    expect(image_list[2]).to be(result[0])
  end
end
# rubocop:enable Style/CollectionMethods
