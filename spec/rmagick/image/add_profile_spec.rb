RSpec.describe Magick::Image, "#add_profile" do
  before do
    @img = described_class.new(20, 20)
  end

  it "works" do
    img = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    expect { img.add_profile(File.join(FIXTURE_PATH, 'cmyk.icm')) }.not_to raise_error
    # expect { img.add_profile(File.join(FIXTURE_PATH, 'srgb.icm')) }.to raise_error(Magick::ImageMagickError)

    img.each_profile { |name, _value| expect(name).to eq('icc') }
    expect { img.delete_profile('icc') }.not_to raise_error
  end
end
