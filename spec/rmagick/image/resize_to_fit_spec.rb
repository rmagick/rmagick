RSpec.describe Magick::Image, '#resize_to_fit' do
  it 'works with two arguments' do
    image = described_class.new(200, 250)
    res = image.resize_to_fit(50, 50)
    expect(res).not_to be(nil)
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)
    expect(res.columns).to eq(40)
    expect(res.rows).to eq(50)
  end

  it 'works with one argument' do
    image = described_class.new(200, 300)
    changed = image.resize_to_fit(100)
    expect(changed).to be_instance_of(described_class)
    expect(changed).not_to be(image)
    expect(changed.columns).to eq(67)
    expect(changed.rows).to eq(100)
  end
end
