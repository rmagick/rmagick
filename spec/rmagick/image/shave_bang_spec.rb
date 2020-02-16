RSpec.describe Magick::Image, '#shave' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.shave!(5, 5)
      expect(res).to be(img)
    end.not_to raise_error
    img.freeze
    expect { img.shave!(2, 2) }.to raise_error(FreezeError)
  end
end
