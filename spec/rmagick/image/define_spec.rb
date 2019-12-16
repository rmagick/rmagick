RSpec.describe Magick::Image, '#define' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect { @img.define('deskew:auto-crop', 40) }.not_to raise_error
    expect { @img.undefine('deskew:auto-crop') }.not_to raise_error
    expect { @img.define('deskew:auto-crop', nil) }.not_to raise_error
  end
end
