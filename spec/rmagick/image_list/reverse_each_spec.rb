RSpec.describe Magick::ImageList, '#reverse_each' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    list.reverse_each { |img| expect(img).to be_instance_of(Magick::Image) }
  end
end
