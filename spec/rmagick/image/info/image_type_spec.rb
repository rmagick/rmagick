RSpec.describe Magick::Image::Info, '#image_type' do
  it 'works' do
    info = described_class.new

    Magick::ImageType.values.each do |v|
      expect { info.image_type = v }.not_to raise_error
      expect(info.image_type).to eq(v)
    end
    expect { info.image_type = nil }.to raise_error(TypeError)
  end
end
