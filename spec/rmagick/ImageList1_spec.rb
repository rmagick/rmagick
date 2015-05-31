RSpec.describe Magick::ImageList do
  describe 'images_from_imagelist' do
    it 'works with identical instances' do
      expect do
        img = Magick::Image.new(1, 1)
        list = Magick::ImageList.new
        list << img << img
        res = list.append(false)
        expect(res.columns).to eq(2)
        expect(res.rows).to eq(1)
      end.not_to raise_error

      expect do
        img = Magick::Image.new(1, 1)
        img2 = Magick::Image.new(3, 3)
        list = Magick::ImageList.new
        list.concat([img, img2, img, img2, img])
        res = list.append(false)
        expect(res.columns).to eq(9)
        expect(res.rows).to eq(3)
      end.not_to raise_error
    end
  end
end
