RSpec.describe Magick::Image, '#marshal' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    d = nil
    img2 = nil
    expect { d = Marshal.dump(img) }.not_to raise_error
    expect { img2 = Marshal.load(d) }.not_to raise_error
    expect(img2).to eq(img)
  end
end
