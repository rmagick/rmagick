RSpec.describe Magick::Image, '#matte_reset!' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.matte_reset!
      expect(res).to be(@img)
    end.not_to raise_error
  end
end
