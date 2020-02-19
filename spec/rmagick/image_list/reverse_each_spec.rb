RSpec.describe Magick::ImageList, '#reverse_each' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image_list.reverse_each { |image| expect(image).to be_instance_of(Magick::Image) }
  end
end
