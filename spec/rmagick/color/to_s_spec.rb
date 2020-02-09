describe Magick::Color, '#to_s' do
  it 'works' do
    color = Magick.colors[0]
    expect(color).to be_instance_of(described_class)
    expect(color.to_s).to match(/name=.+, compliance=.+, color.red=.+, color.green=.+, color.blue=.+, color.alpha=.+/)
  end
end
