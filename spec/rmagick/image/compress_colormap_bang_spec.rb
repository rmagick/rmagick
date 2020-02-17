RSpec.describe Magick::Image, '#compress_colormap!' do
  it 'works' do
    image = described_class.new(20, 20)
    # DirectClass images are converted to PseudoClass in older versions of ImageMagick.
    expect(image.class_type).to eq(Magick::DirectClass)
    expect { image.compress_colormap! }.not_to raise_error
    # expect(image.class_type).to eq(Magick::PseudoClass)
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    expect(image.class_type).to eq(Magick::PseudoClass)
    expect { image.compress_colormap! }.not_to raise_error
  end
end
