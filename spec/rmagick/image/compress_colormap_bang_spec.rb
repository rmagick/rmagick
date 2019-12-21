RSpec.describe Magick::Image, '#compress_colormap!' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    # DirectClass images are converted to PseudoClass in older versions of ImageMagick.
    expect(@img.class_type).to eq(Magick::DirectClass)
    expect { @img.compress_colormap! }.not_to raise_error
    # expect(@img.class_type).to eq(Magick::PseudoClass)
    @img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    expect(@img.class_type).to eq(Magick::PseudoClass)
    expect { @img.compress_colormap! }.not_to raise_error
  end
end
