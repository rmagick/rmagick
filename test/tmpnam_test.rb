require 'minitest/autorun'
require 'rmagick'

class TmpnamTest < Minitest::Test
  # test the @@_tmpnam_ class variable
  # the count is incremented by Image::Info#texture=,
  # ImageList::Montage#texture=, and Draw.composite
  def test_tmpnam
    tmpfiles = Dir[ENV['HOME'] + '/tmp/magick*'].length

    texture = Magick::Image.read('granite:') { self.size = '20x20' }.first
    info = Magick::Image::Info.new

    # does not exist at first
    assert_raise(NameError) { Magick._tmpnam_ }

    info.texture = texture

    # now it exists
    assert_nothing_raised { Magick._tmpnam_ }
    assert_equal(1, Magick._tmpnam_)

    info.texture = texture
    assert_equal(2, Magick._tmpnam_)

    mon = Magick::ImageList::Montage.new
    mon.texture = texture
    assert_equal(3, Magick._tmpnam_)

    mon.texture = texture
    assert_equal(4, Magick._tmpnam_)

    gc = Magick::Draw.new
    gc.composite(0, 0, 20, 20, texture)
    assert_equal(5, Magick._tmpnam_)

    gc.composite(0, 0, 20, 20, texture)
    assert_equal(6, Magick._tmpnam_)

    tmpfiles2 = Dir[ENV['HOME'] + '/tmp/magick*'].length

    # The 2nd montage texture deletes the first.
    # The 2nd info texture deletes the first.
    # Both composite images are still alive.
    # Therefore only 4 tmp files are left.
    # assert_equal(tmpfiles+4, tmpfiles2)
    # 6.4.1-5 - only 1 tmpfile?
    assert_equal(tmpfiles, tmpfiles2)
  end
end
