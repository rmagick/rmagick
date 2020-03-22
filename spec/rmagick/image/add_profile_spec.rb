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
end
