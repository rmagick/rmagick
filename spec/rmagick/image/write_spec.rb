RSpec.describe Magick::Image, '#write' do
  it 'works' do
    image1 = described_class.new(20, 20)

    image1.write('temp.gif')
    image2 = described_class.read('temp.gif')
    expect(image2.first.format).to eq('GIF')
    FileUtils.rm('temp.gif')

    image1.write('jpg:temp.foo')
    image2 = described_class.read('temp.foo')
    expect(image2.first.format).to eq('JPEG')
    FileUtils.rm('temp.foo')

    image1.write('temp.0') { self.format = 'JPEG' }
    image2 = described_class.read('temp.0')
    expect(image2.first.format).to eq('JPEG')

    # JPEG has two names.
    image1.write('jpeg:temp.0') { self.format = 'JPEG' }
    image2 = described_class.read('temp.0')
    expect(image2.first.format).to eq('JPEG')

    image1.write('jpg:temp.0') { self.format = 'JPG' }
    image2 = described_class.read('temp.0')
    expect(image2.first.format).to eq('JPEG')

    image1.write('jpg:temp.0') { self.format = 'JPEG' }
    image2 = described_class.read('temp.0')
    expect(image2.first.format).to eq('JPEG')

    image1.write('jpeg:temp.0') { self.format = 'JPG' }
    image2 = described_class.read('temp.0')
    expect(image2.first.format).to eq('JPEG')

    expect do
      image1.write('gif:temp.0') { self.format = 'JPEG' }
    end.to raise_error(RuntimeError)

    f = File.new('test.0', 'w')
    image1.write(f) { self.format = 'JPEG' }
    f.close
    image2 = described_class.read('test.0')
    expect(image2.first.format).to eq('JPEG')
    FileUtils.rm('test.0')

    image1.write('test.webp')
    image2 = described_class.read('test.webp')
    expect(image2.first.format).to eq('WEBP')
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
    image2 = described_class.read('test.0')
    expect(image2.first.format).to eq('JPEG')
    FileUtils.rm('test.0')
  end
end
