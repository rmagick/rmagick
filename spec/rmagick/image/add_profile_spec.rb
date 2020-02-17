RSpec.describe Magick::Image, "#add_profile" do
  it "works" do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    expect { image.add_profile(File.join(FIXTURE_PATH, 'cmyk.icm')) }.not_to raise_error
    # expect { image.add_profile(File.join(FIXTURE_PATH, 'srgb.icm')) }.to raise_error(Magick::ImageMagickError)

    image.each_profile { |name, _value| expect(name).to eq('icc') }
    expect { image.delete_profile('icc') }.not_to raise_error
  end
end
