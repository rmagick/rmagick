RSpec.describe Magick::Image, '#get_exif_by_entry' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.get_exif_by_entry
    expect(res).to be_instance_of(Array)
  end
end
