require 'rmagick'
require 'minitest/autorun'

class LibMagickUT < Minitest::Test
  def test_formats
    assert_instance_of(Hash, Magick.formats)
    Magick.formats.each do |f, v|
      assert_instance_of(String, f)
      assert_match(/[\*\+\srw]+/, v)
    end

    Magick.formats do |f, v|
      assert_instance_of(String, f)
      assert_match(/[\*\+\srw]+/, v)
    end
  end

  def test_trace_proc
    Magick.trace_proc = proc do |which, description, id, method|
      assert(which == :c)
      assert_instance_of(String, description)
      assert_instance_of(String, id)
      expect(method).to eq(:initialize)
    end
    img = Magick::Image.new(20, 20)

    Magick.trace_proc = proc do |which, description, id, method|
      assert(which == :d)
      assert_instance_of(String, description)
      assert_instance_of(String, id)
      expect(method).to eq(:"destroy!")
    end
    img.destroy!
  ensure
    Magick.trace_proc = nil
  end
end
