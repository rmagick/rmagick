RSpec.describe Magick::Image, '#equalize' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.equalize
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
  end
end
