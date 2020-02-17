RSpec.describe Magick::Image, '#shave' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.shave!(5, 5)
    expect(res).to be(img)

    img.freeze
    expect { img.shave!(2, 2) }.to raise_error(FreezeError)
  end
end
