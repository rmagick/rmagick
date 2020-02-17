RSpec.describe Magick::Image, '#cycle_colormap' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.cycle_colormap(5)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)
    expect(result.class_type).to eq(Magick::PseudoClass)
  end
end
