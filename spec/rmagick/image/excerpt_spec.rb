RSpec.describe Magick::Image, '#excerpt' do
  it 'works' do
    img1 = described_class.new(20, 20)
    img2 = described_class.new(200, 200)

    res = nil
    expect { res = img1.excerpt(20, 20, 50, 100) }.not_to raise_error
    expect(res).not_to be(img2)
    expect(res.columns).to eq(50)
    expect(res.rows).to eq(100)

    expect { img2.excerpt!(20, 20, 50, 100) }.not_to raise_error
    expect(img2.columns).to eq(50)
    expect(img2.rows).to eq(100)
  end
end
