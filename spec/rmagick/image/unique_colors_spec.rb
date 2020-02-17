RSpec.describe Magick::Image, '#unique_colors' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.unique_colors
    expect(res).to be_instance_of(described_class)
    expect(res.columns).to eq(1)
    expect(res.rows).to eq(1)
  end
end
