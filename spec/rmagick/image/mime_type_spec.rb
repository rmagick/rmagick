RSpec.describe Magick::Image, '#mime_type' do
  it 'works' do
    img1 = described_class.new(100, 100)
    img2 = img1.copy
    img2.format = 'GIF'

    expect { img2.mime_type }.not_to raise_error
    expect(img2.mime_type).to eq('image/gif')
    img2.format = 'JPG'
    expect(img2.mime_type).to eq('image/jpeg')
    expect { img2.mime_type = 'image/jpeg' }.to raise_error(NoMethodError)
  end
end
