RSpec.describe Magick::Image, '#get_exif_by_number' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.get_exif_by_number
    expect(res).to be_instance_of(Hash)
  end
end
