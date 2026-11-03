# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Magick::Image, "#add_profile" do
  it "works" do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    expect { image.add_profile(File.join(FIXTURE_PATH, 'cmyk.icm')) }.not_to raise_error
    expect(image.color_profile).not_to be(nil)

    image.each_profile { |name, _value| expect(name).to eq('icc') }
    expect { image.delete_profile('icc') }.not_to raise_error
  end

  it "can add profile even if an image does not have profile" do
    image = described_class.new(100, 100)
    image.add_profile(File.join(FIXTURE_PATH, 'cmyk.icm'))
    expect(image.color_profile).not_to be(nil)
  end

  it "adds the profiles of the first image of a file with several images and frees them all" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'pages.tif')
      pages = Magick::ImageList.new
      3.times { pages << described_class.new(100, 100) }
      pages.first.add_profile(File.join(FIXTURE_PATH, 'cmyk.icm'))
      pages.write(path)
      image = described_class.new(10, 10)
      GC.start
      before = pixel_cache_size

      5.times { image.add_profile(path) }

      expect(pixel_cache_size).to eq(before)
      expect(image.color_profile).not_to be(nil)
    end
  end
end
