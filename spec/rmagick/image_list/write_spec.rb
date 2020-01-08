RSpec.describe Magick::ImageList, "#write" do
  before do
    @ilist = Magick::ImageList.new
  end

  it "works" do
    @ilist.read(IMAGES_DIR + '/Button_0.gif')
    expect do
      @ilist.write('temp.gif')
    end.not_to raise_error
    list = Magick::ImageList.new('temp.gif')
    expect(list.format).to eq('GIF')
    FileUtils.rm('temp.gif')

    @ilist.write('jpg:temp.foo')
    list = Magick::ImageList.new('temp.foo')
    expect(list.format).to eq('JPEG')
    FileUtils.rm('temp.foo')

    @ilist.write('temp.0') { self.format = 'JPEG' }
    list = Magick::ImageList.new('temp.0')
    expect(list.format).to eq('JPEG')
    FileUtils.rm('temp.0')

    f = File.new('test.0', 'w')
    @ilist.write(f) { self.format = 'JPEG' }
    f.close
    list = Magick::ImageList.new('test.0')
    expect(list.format).to eq('JPEG')
    FileUtils.rm('test.0')
  end
end
