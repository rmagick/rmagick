RSpec.describe Magick::Image, '#magnify' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.magnify
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error

    res = @img.magnify!
    expect(res).to be(@img)
  end
end
