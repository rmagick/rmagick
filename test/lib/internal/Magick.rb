require 'rmagick'
require 'minitest/autorun'

describe Magick do
  describe '#formats' do
    it 'works' do
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
  end

  describe '#trace_proc' do
    it 'works' do
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
    end

    after do
      Magick.trace_proc = nil
    end
  end
end
