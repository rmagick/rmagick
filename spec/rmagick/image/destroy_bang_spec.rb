RSpec.describe Magick::Image, '#destroy!' do
  after do
    GC.enable
    Magick.trace_proc = nil
  end

  it 'works' do
    images = {}
    GC.disable

    Magick.trace_proc = proc do |which, id, addr, method|
      m = id.split(/ /)
      name = File.basename m[0]

      case which
      when :c
        expect(images).not_to have_key(addr)
        images[addr] = name
      when :d
        expect(method).to eq(:destroy!)
        expect(images).to have_key(addr)
        expect(images[addr]).to eq(name)
      else
        raise ArgumentError, "Unhandled `which`: #{which.inspect}"
      end
    end

    unmapped = Magick::ImageList.new(IMAGES_DIR + '/Hot_Air_Balloons.jpg', IMAGES_DIR + '/Violin.jpg', IMAGES_DIR + '/Polynesia.jpg')
    map = Magick::ImageList.new 'netscape:'
    mapped = unmapped.remap map
    unmapped.each(&:destroy!)
    map.destroy!
    mapped.each(&:destroy!)
  end
end
