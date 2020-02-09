RSpec.describe Magick::Image, '#write' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    @img.write('temp.gif')
    img = described_class.read('temp.gif')
    expect(img.first.format).to eq('GIF')
    FileUtils.rm('temp.gif')

    @img.write('jpg:temp.foo')
    img = described_class.read('temp.foo')
    expect(img.first.format).to eq('JPEG')
    FileUtils.rm('temp.foo')

    @img.write('temp.0') { self.format = 'JPEG' }
    img = described_class.read('temp.0')
    expect(img.first.format).to eq('JPEG')

    # JPEG has two names.
    @img.write('jpeg:temp.0') { self.format = 'JPEG' }
    img = described_class.read('temp.0')
    expect(img.first.format).to eq('JPEG')

    @img.write('jpg:temp.0') { self.format = 'JPG' }
    img = described_class.read('temp.0')
    expect(img.first.format).to eq('JPEG')

    @img.write('jpg:temp.0') { self.format = 'JPEG' }
    img = described_class.read('temp.0')
    expect(img.first.format).to eq('JPEG')

    @img.write('jpeg:temp.0') { self.format = 'JPG' }
    img = described_class.read('temp.0')
    expect(img.first.format).to eq('JPEG')

    expect do
      @img.write('gif:temp.0') { self.format = 'JPEG' }
    end.to raise_error(RuntimeError)

    f = File.new('test.0', 'w')
    @img.write(f) { self.format = 'JPEG' }
    f.close
    img = described_class.read('test.0')
    expect(img.first.format).to eq('JPEG')
    FileUtils.rm('test.0')

    @img.write('test.webp')
    img = described_class.read('test.webp')
    expect(img.first.format).to eq('WEBP')
    begin
      FileUtils.rm('test.webp')
    rescue StandardError
      nil
    end # Avoid failure on AppVeyor

    f = File.new('test.0', 'w')
    described_class.new(100, 100).write(f) do
      self.format = 'JPEG'
      self.colorspace = Magick::CMYKColorspace
    end
    f.close
    img = described_class.read('test.0')
    expect(img.first.format).to eq('JPEG')
    FileUtils.rm('test.0')
  end
end
