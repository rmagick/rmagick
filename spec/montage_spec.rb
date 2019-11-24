RSpec.describe Magick::ImageList do
  def assert_same_image(expected_image_path, image_object, delta: 0.01)
    expected = Magick::Image.read(expected_image_path).first
    _, error = expected.compare_channel(image_object, Magick::MeanSquaredErrorMetric)
    expect(error).to be_within(delta).of(0.0)
  end

  describe '#color' do
    it 'works' do
      imagelist = Magick::ImageList.new(IMAGES_DIR + '/Flower_Hat.jpg')

      new_imagelist = imagelist.montage do
        self.border_width = 100
        self.border_color = 'red'
        self.background_color = 'blue'
        self.matte_color = 'yellow'
        self.frame = '10x10'
        self.gravity = Magick::CenterGravity
      end

      # montage ../../doc/ex/images/Flower_Hat.jpg -border 100x -bordercolor red -mattecolor yellow -background blue -frame 10x10 -gravity Center expected/montage_border_color.jpg
      assert_same_image(File.join(FIXTURE_PATH, 'montage_border_color.jpg'), new_imagelist.first)
    end
  end
end
