RSpec.describe Magick::Image, '#excerpt' do
  it 'works' do
    image1 = described_class.new(20, 20)
    image2 = described_class.new(200, 200)

    res = image1.excerpt(20, 20, 50, 100)
    expect(res).not_to be(image2)
    expect(res.columns).to eq(50)
    expect(res.rows).to eq(100)

    image2.excerpt!(20, 20, 50, 100)
    expect(image2.columns).to eq(50)
    expect(image2.rows).to eq(100)
  end
end
