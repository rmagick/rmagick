RSpec.describe Magick::Image, '#mime_type' do
  it 'works' do
    image1 = described_class.new(100, 100)
    image2 = image1.copy
    image2.format = 'GIF'

    expect { image2.mime_type }.not_to raise_error
    expect(image2.mime_type).to eq('image/gif')
    image2.format = 'JPG'
    expect(image2.mime_type).to eq('image/jpeg')
    expect { image2.mime_type = 'image/jpeg' }.to raise_error(NoMethodError)
  end
end
