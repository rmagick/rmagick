require 'rmagick'
require 'minitest/autorun'

class LibMagickUT < Minitest::Test
  def test_formats
    expect(Magick.formats).to be_instance_of(Hash)
    Magick.formats.each do |f, v|
      expect(f).to be_instance_of(String)
      assert_match(/[\*\+\srw]+/, v)
    end

    Magick.formats do |f, v|
      expect(f).to be_instance_of(String)
      assert_match(/[\*\+\srw]+/, v)
    end
  end

  def test_trace_proc
    Magick.trace_proc = proc do |which, description, id, method|
      assert(which == :c)
      expect(description).to be_instance_of(String)
      expect(id).to be_instance_of(String)
      expect(method).to eq(:initialize)
    end
    img = Magick::Image.new(20, 20)

    Magick.trace_proc = proc do |which, description, id, method|
      assert(which == :d)
      expect(description).to be_instance_of(String)
      expect(id).to be_instance_of(String)
      expect(method).to eq(:"destroy!")
    end
    img.destroy!
  ensure
    Magick.trace_proc = nil
  end

  def test_trace_proc_segfault
    def create_img
      local_img = Magick::Image.new(20, 20)
    end

    create_img
    GC.stress = true

    proc1 = proc do |which, id, addr, method|
      assert(which == :c)
    end

    Magick.trace_proc = proc1
    Magick::Image.new(777, 777)
  ensure
    GC.stress = false
  end
end
