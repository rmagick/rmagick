RSpec.describe Magick::Image, '#offset' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.offset }.not_to raise_error
    expect(image.offset).to eq(0)
    expect { image.offset = 10 }.not_to raise_error
    expect(image.offset).to eq(10)
    expect { image.offset = 'x' }.to raise_error(TypeError)
  end
end
