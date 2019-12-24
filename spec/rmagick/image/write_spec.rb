RSpec.describe Magick::Image, '#write' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    @img.write('temp.gif')
    img = Magick::Image.read('temp.gif')
    expect(img.first.format).to eq('GIF')
    FileUtils.rm('temp.gif')

    @img.write('jpg:temp.foo')
    img = Magick::Image.read('temp.foo')
    expect(img.first.format).to eq('JPEG')
    FileUtils.rm('temp.foo')

    @img.write('temp.0') { self.format = 'JPEG' }
    img = Magick::Image.read('temp.0')
    expect(img.first.format).to eq('JPEG')

    # JPEG has two names.
    @img.write('jpeg:temp.0') { self.format = 'JPEG' }
    img = Magick::Image.read('temp.0')
    expect(img.first.format).to eq('JPEG')

    @img.write('jpg:temp.0') { self.format = 'JPG' }
    img = Magick::Image.read('temp.0')
    expect(img.first.format).to eq('JPEG')

    @img.write('jpg:temp.0') { self.format = 'JPEG' }
    img = Magick::Image.read('temp.0')
    expect(img.first.format).to eq('JPEG')

    @img.write('jpeg:temp.0') { self.format = 'JPG' }
    img = Magick::Image.read('temp.0')
    expect(img.first.format).to eq('JPEG')

    expect do
      @img.write('gif:temp.0') { self.format = 'JPEG' }
    end.to raise_error(RuntimeError)

    f = File.new('test.0', 'w')
    @img.write(f) { self.format = 'JPEG' }
    f.close
    img = Magick::Image.read('test.0')
    expect(img.first.format).to eq('JPEG')
    FileUtils.rm('test.0')

    @img.write('test.webp')
    img = Magick::Image.read('test.webp')
    expect(img.first.format).to eq('WEBP')
    begin
      FileUtils.rm('test.webp')
    rescue StandardError
      nil
    end # Avoid failure on AppVeyor

    f = File.new('test.0', 'w')
    Magick::Image.new(100, 100).write(f) do
      self.format = 'JPEG'
      self.colorspace = Magick::CMYKColorspace
    end
    f.close
    img = Magick::Image.read('test.0')
    expect(img.first.format).to eq('JPEG')
    FileUtils.rm('test.0')
  end
end
