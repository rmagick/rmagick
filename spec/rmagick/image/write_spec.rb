RSpec.describe Magick::Image, '#write' do
  it 'works' do
    img1 = described_class.new(20, 20)

    img1.write('temp.gif')
    img2 = described_class.read('temp.gif')
    expect(img2.first.format).to eq('GIF')
    FileUtils.rm('temp.gif')

    img1.write('jpg:temp.foo')
    img2 = described_class.read('temp.foo')
    expect(img2.first.format).to eq('JPEG')
    FileUtils.rm('temp.foo')

    img1.write('temp.0') { self.format = 'JPEG' }
    img2 = described_class.read('temp.0')
    expect(img2.first.format).to eq('JPEG')

    # JPEG has two names.
    img1.write('jpeg:temp.0') { self.format = 'JPEG' }
    img2 = described_class.read('temp.0')
    expect(img2.first.format).to eq('JPEG')

    img1.write('jpg:temp.0') { self.format = 'JPG' }
    img2 = described_class.read('temp.0')
    expect(img2.first.format).to eq('JPEG')

    img1.write('jpg:temp.0') { self.format = 'JPEG' }
    img2 = described_class.read('temp.0')
    expect(img2.first.format).to eq('JPEG')

    img1.write('jpeg:temp.0') { self.format = 'JPG' }
    img2 = described_class.read('temp.0')
    expect(img2.first.format).to eq('JPEG')

    expect do
      img1.write('gif:temp.0') { self.format = 'JPEG' }
    end.to raise_error(RuntimeError)

    f = File.new('test.0', 'w')
    img1.write(f) { self.format = 'JPEG' }
    f.close
    img2 = described_class.read('test.0')
    expect(img2.first.format).to eq('JPEG')
    FileUtils.rm('test.0')

    img1.write('test.webp')
    img2 = described_class.read('test.webp')
    expect(img2.first.format).to eq('WEBP')
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
    img2 = described_class.read('test.0')
    expect(img2.first.format).to eq('JPEG')
    FileUtils.rm('test.0')
  end
end
