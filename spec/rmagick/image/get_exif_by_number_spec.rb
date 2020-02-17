RSpec.describe Magick::Image, '#get_exif_by_number' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.get_exif_by_number
    expect(result).to be_instance_of(Hash)
  end
end
