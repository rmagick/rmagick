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
    expect { Magick._tmpnam_ }.to raise_error(NameError)

    info.texture = texture

    # now it exists
    assert_nothing_raised { Magick._tmpnam_ }
    expect(Magick._tmpnam_).to eq(1)

    info.texture = texture
    expect(Magick._tmpnam_).to eq(2)

    mon = Magick::ImageList::Montage.new
    mon.texture = texture
    expect(Magick._tmpnam_).to eq(3)

    mon.texture = texture
    expect(Magick._tmpnam_).to eq(4)

    gc = Magick::Draw.new
    gc.composite(0, 0, 20, 20, texture)
    expect(Magick._tmpnam_).to eq(5)

    gc.composite(0, 0, 20, 20, texture)
    expect(Magick._tmpnam_).to eq(6)

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
