RSpec.describe Magick::ImageList, "#write" do
  it "works" do
    image_list = described_class.new

    image_list.read(IMAGES_DIR + '/Button_0.gif')

    image_list.write('temp.gif')

    image_list = described_class.new('temp.gif')
    expect(image_list.format).to eq('GIF')
    FileUtils.rm('temp.gif')

    image_list.write('jpg:temp.foo')
    image_list = described_class.new('temp.foo')
    expect(image_list.format).to eq('JPEG')
    FileUtils.rm('temp.foo')

    image_list.write('temp.0') { self.format = 'JPEG' }
    image_list = described_class.new('temp.0')
    expect(image_list.format).to eq('JPEG')
    FileUtils.rm('temp.0')

    f = File.new('test.0', 'w')
    image_list.write(f) { self.format = 'JPEG' }
    f.close
    image_list = described_class.new('test.0')
    expect(image_list.format).to eq('JPEG')
    FileUtils.rm('test.0')
  end
end
