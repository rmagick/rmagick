RSpec.describe Magick do
  # test the @@_tmpnam_ class variable
  # the count is incremented by Image::Info#texture=,
  # ImageList::Montage#texture=, and Draw.composite
  describe '#tmpnam' do
    it 'works' do
      tmpfiles = Dir[ENV['HOME'] + '/tmp/magick*'].length

      texture = Magick::Image.read('granite:') { self.size = '20x20' }.first
      info = Magick::Image::Info.new

      # does not exist at first
      # expect { Magick._tmpnam_ }.to raise_error(NameError)

      info.texture = texture

      # now it exists
      expect { Magick._tmpnam_ }.not_to raise_error
      original_tmpnam = Magick._tmpnam_

      info.texture = texture
      expect(Magick._tmpnam_).to eq(original_tmpnam + 1)

      mon = Magick::ImageList::Montage.new
      mon.texture = texture
      expect(Magick._tmpnam_).to eq(original_tmpnam + 2)

      mon.texture = texture
      expect(Magick._tmpnam_).to eq(original_tmpnam + 3)

      gc = Magick::Draw.new
      gc.composite(0, 0, 20, 20, texture)
      expect(Magick._tmpnam_).to eq(original_tmpnam + 4)

      gc.composite(0, 0, 20, 20, texture)
      expect(Magick._tmpnam_).to eq(original_tmpnam + 5)

      tmpfiles2 = Dir[ENV['HOME'] + '/tmp/magick*'].length

      # The 2nd montage texture deletes the first.
      # The 2nd info texture deletes the first.
      # Both composite images are still alive.
      # Therefore only 4 tmp files are left.
      # expect(tmpfiles2).to eq(tmpfiles+4)
      # 6.4.1-5 - only 1 tmpfile?
      expect(tmpfiles2).to eq(tmpfiles)
    end
  end
end
