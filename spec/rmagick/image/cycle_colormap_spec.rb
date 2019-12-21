RSpec.describe Magick::Image, '#cycle_colormap' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.cycle_colormap(5)
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
      expect(res.class_type).to eq(Magick::PseudoClass)
    end.not_to raise_error
  end
end
