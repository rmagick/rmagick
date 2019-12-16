RSpec.describe Magick::Image, '#oil_paint' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.oil_paint
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.oil_paint(2.0) }.not_to raise_error
    expect { @img.oil_paint(2.0, 1.0) }.to raise_error(ArgumentError)
  end
end
