RSpec.describe Magick::Image::Info, '#texture' do
  it 'works' do
    info = described_class.new
    img = Magick::Image.read('granite:') { self.size = '20x20' }

    expect { info.texture = img.first }.not_to raise_error
    expect { info.texture = nil }.not_to raise_error
  end
end
