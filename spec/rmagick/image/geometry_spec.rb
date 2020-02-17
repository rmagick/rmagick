RSpec.describe Magick::Image, '#geometry' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.geometry }.not_to raise_error
    expect(image.geometry).to be(nil)
    expect { image.geometry = nil }.not_to raise_error
    expect { image.geometry = '90x90' }.not_to raise_error
    expect(image.geometry).to eq('90x90')
    expect { image.geometry = Magick::Geometry.new(100, 80) }.not_to raise_error
    expect(image.geometry).to eq('100x80')
    expect { image.geometry = [] }.to raise_error(TypeError)
  end
end
