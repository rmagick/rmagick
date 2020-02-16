RSpec.describe Magick::Image, '#rotate!' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.rotate!(45)
      expect(res).to be(img)
    end.not_to raise_error
    img.freeze
    expect { img.rotate!(45) }.to raise_error(FreezeError)
  end
end
