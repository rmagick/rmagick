RSpec.describe Magick::Image, '#page' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.page }.not_to raise_error
    page = img.page
    expect(page.width).to eq(0)
    expect(page.height).to eq(0)
    expect(page.x).to eq(0)
    expect(page.y).to eq(0)
    page = Magick::Rectangle.new(1, 2, 3, 4)
    expect { img.page = page }.not_to raise_error
    expect(page.width).to eq(1)
    expect(page.height).to eq(2)
    expect(page.x).to eq(3)
    expect(page.y).to eq(4)
    expect { img.page = 2 }.to raise_error(TypeError)
  end
end
