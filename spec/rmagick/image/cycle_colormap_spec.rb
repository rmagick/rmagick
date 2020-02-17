RSpec.describe Magick::Image, '#cycle_colormap' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.cycle_colormap(5)
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(img)
    expect(res.class_type).to eq(Magick::PseudoClass)
  end
end
