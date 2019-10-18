require 'rmagick'
require 'minitest/autorun'

class LibMagickUT < Minitest::Test
  def test_formats
    expect(Magick.formats).to be_instance_of(Hash)
    Magick.formats.each do |f, v|
      expect(f).to be_instance_of(String)
      expect(v).to match(/[\*\+\srw]+/)
    end

    Magick.formats do |f, v|
      expect(f).to be_instance_of(String)
      expect(v).to match(/[\*\+\srw]+/)
    end
  end

  def test_trace_proc
    Magick.trace_proc = proc do |which, description, id, method|
      expect(which).to eq(:c)
      expect(description).to be_instance_of(String)
      expect(id).to be_instance_of(String)
      expect(method).to eq(:initialize)
    end
    img = Magick::Image.new(20, 20)

    Magick.trace_proc = proc do |which, description, id, method|
      expect(which).to eq(:d)
      expect(description).to be_instance_of(String)
      expect(id).to be_instance_of(String)
      expect(method).to eq(:"destroy!")
    end
    img.destroy!
  ensure
    Magick.trace_proc = nil
  end
end
