RSpec.describe Magick::Image, '#copy' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      ditto = @img.copy
      expect(ditto).to eq(@img)
    end.not_to raise_error
  end
end
