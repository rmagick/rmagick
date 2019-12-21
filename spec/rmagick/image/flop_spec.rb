RSpec.describe Magick::Image, '#flop' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.flop
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
  end
end
