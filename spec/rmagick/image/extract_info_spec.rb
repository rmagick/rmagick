RSpec.describe Magick::Image, '#extract_info' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.extract_info }.not_to raise_error
    expect(image.extract_info).to be_instance_of(Magick::Rectangle)
    ext = image.extract_info
    expect(ext.x).to eq(0)
    expect(ext.y).to eq(0)
    expect(ext.width).to eq(0)
    expect(ext.height).to eq(0)
    ext = Magick::Rectangle.new(1, 2, 3, 4)
    expect { image.extract_info = ext }.not_to raise_error
    expect(ext.width).to eq(1)
    expect(ext.height).to eq(2)
    expect(ext.x).to eq(3)
    expect(ext.y).to eq(4)
    expect { image.extract_info = 2 }.to raise_error(TypeError)
  end
end
