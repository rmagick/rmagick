RSpec.describe Magick::Image, '#define' do
  it 'works' do
    image = described_class.new(20, 20)

    expect { image.define('deskew:auto-crop', 40) }.not_to raise_error
    expect { image.undefine('deskew:auto-crop') }.not_to raise_error
    expect { image.define('deskew:auto-crop', nil) }.not_to raise_error
  end
end
