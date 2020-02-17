RSpec.describe Magick::Image, '#unique_colors' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.unique_colors
    expect(result).to be_instance_of(described_class)
    expect(result.columns).to eq(1)
    expect(result.rows).to eq(1)
  end
end
