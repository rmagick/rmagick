RSpec.describe Magick::Image, '#mask' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    cimg = described_class.new(10, 10)
    expect { @img.mask(cimg) }.not_to raise_error
    res = nil
    expect { res = @img.mask }.not_to raise_error
    expect(res).not_to be(nil)
    expect(res).not_to be(cimg)
    expect(res.columns).to eq(20)
    expect(res.rows).to eq(20)

    expect { @img.mask(cimg, 'x') }.to raise_error(ArgumentError)
    # mask expects an Image and calls `cur_image'
    expect { @img.mask = 2 }.to raise_error(NoMethodError)

    img2 = @img.copy.freeze
    expect { img2.mask cimg }.to raise_error(FreezeError)

    @img.destroy!
    expect { @img.mask cimg }.to raise_error(Magick::DestroyedImageError)
  end
end
