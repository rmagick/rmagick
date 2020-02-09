RSpec.describe Magick::Image, '#resize_to_fit!' do
  it 'works' do
    img = described_class.new(200, 300)
    img.resize_to_fit!(100)
    expect(img).to be_instance_of(described_class)
    expect(img.columns).to eq(67)
    expect(img.rows).to eq(100)
  end
end
