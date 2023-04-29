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

    image_list.write('temp.0') { |options| options.format = 'JPEG' }
    image_list = described_class.new('temp.0')
    expect(image_list.format).to eq('JPEG')
    FileUtils.rm('temp.0')

    f = File.new('test.0', 'w')
    image_list.write(f) { |options| options.format = 'JPEG' }
    f.close
    image_list = described_class.new('test.0')
    expect(image_list.format).to eq('JPEG')
    FileUtils.rm('test.0')
  end

  it "issue #1375" do
    # https://commons.wikimedia.org/wiki/File:Animhorse.gif
    image_list = described_class.new(File.join(FIXTURE_PATH, 'animhorse.gif'))

    File.open(File.join(Dir.tmpdir, 'out.gif'), 'w') do |f|
      image_list.write(f)
    end

    Tempfile.open('out.gif') do |f|
      image_list.write(f)
    end
  end
end
