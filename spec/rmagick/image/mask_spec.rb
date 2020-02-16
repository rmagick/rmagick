RSpec.describe Magick::Image, '#mask' do
  it 'works' do
    img1 = described_class.new(20, 20)
    cimg = described_class.new(10, 10)

    expect { img1.mask(cimg) }.not_to raise_error
    res = nil
    expect { res = img1.mask }.not_to raise_error
    expect(res).not_to be(nil)
    expect(res).not_to be(cimg)
    expect(res.columns).to eq(20)
    expect(res.rows).to eq(20)

    expect { img1.mask(cimg, 'x') }.to raise_error(ArgumentError)
    # mask expects an Image and calls `cur_image'
    expect { img1.mask = 2 }.to raise_error(NoMethodError)

    img2 = img1.copy.freeze
    expect { img2.mask cimg }.to raise_error(FreezeError)

    img1.destroy!
    expect { img1.mask cimg }.to raise_error(Magick::DestroyedImageError)
  end
end
