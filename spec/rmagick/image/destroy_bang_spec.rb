RSpec.describe Magick::Image, '#destroy!' do
  it 'works' do
    unmapped = Magick::ImageList.new(IMAGES_DIR + '/Hot_Air_Balloons.jpg', IMAGES_DIR + '/Violin.jpg', IMAGES_DIR + '/Polynesia.jpg')
    map = Magick::ImageList.new 'netscape:'
    mapped = unmapped.remap map
    unmapped.each(&:destroy!)
    map.destroy!
    mapped.each(&:destroy!)
  end
end
