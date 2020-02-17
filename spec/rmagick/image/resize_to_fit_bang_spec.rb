RSpec.describe Magick::Image, '#resize_to_fit!' do
  it 'works' do
    image = described_class.new(200, 300)
    image.resize_to_fit!(100)
    expect(image).to be_instance_of(described_class)
    expect(image.columns).to eq(67)
    expect(image.rows).to eq(100)
  end
end
