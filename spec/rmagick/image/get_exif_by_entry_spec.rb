RSpec.describe Magick::Image, '#get_exif_by_entry' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.get_exif_by_entry
    expect(res).to be_instance_of(Array)
  end
end
