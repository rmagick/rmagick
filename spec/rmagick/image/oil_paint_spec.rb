RSpec.describe Magick::Image, '#oil_paint' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.oil_paint
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(img)
    end.not_to raise_error
    expect { img.oil_paint(2.0) }.not_to raise_error
    expect { img.oil_paint(2.0, 1.0) }.to raise_error(ArgumentError)
  end
end
