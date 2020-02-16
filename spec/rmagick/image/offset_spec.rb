RSpec.describe Magick::Image, '#offset' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.offset }.not_to raise_error
    expect(img.offset).to eq(0)
    expect { img.offset = 10 }.not_to raise_error
    expect(img.offset).to eq(10)
    expect { img.offset = 'x' }.to raise_error(TypeError)
  end
end
