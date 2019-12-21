RSpec.describe Magick::Image, '#excerpt' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    res = nil
    img = Magick::Image.new(200, 200)
    expect { res = @img.excerpt(20, 20, 50, 100) }.not_to raise_error
    expect(res).not_to be(img)
    expect(res.columns).to eq(50)
    expect(res.rows).to eq(100)

    expect { img.excerpt!(20, 20, 50, 100) }.not_to raise_error
    expect(img.columns).to eq(50)
    expect(img.rows).to eq(100)
  end
end
