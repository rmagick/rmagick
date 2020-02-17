RSpec.describe Magick::Image, '#resize_to_fill' do
  it 'does not change image when using the same dimensions' do
    image = described_class.new(20, 20)

    changed = image.resize_to_fill(image.columns, image.rows)
    expect(changed.columns).to eq(image.columns)
    expect(changed.rows).to eq(image.rows)
    expect(image).not_to be(changed)
  end

  it 'resizes to the given dimensions' do
    image = described_class.new(200, 250)

    image.resize_to_fill!(100, 100)
    expect(image.columns).to eq(100)
    expect(image.rows).to eq(100)

    image = described_class.new(200, 250)
    changed = image.resize_to_fill(300, 100)
    expect(changed.columns).to eq(300)
    expect(changed.rows).to eq(100)

    image = described_class.new(200, 250)
    changed = image.resize_to_fill(100, 300)
    expect(changed.columns).to eq(100)
    expect(changed.rows).to eq(300)

    image = described_class.new(200, 250)
    changed = image.resize_to_fill(300, 350)
    expect(changed.columns).to eq(300)
    expect(changed.rows).to eq(350)

    image = described_class.new(200, 250)
    changed = image.resize_to_fill(20, 400)
    expect(changed.columns).to eq(20)
    expect(changed.rows).to eq(400)

    image = described_class.new(200, 250)
    changed = image.resize_to_fill(3000, 400)
    expect(changed.columns).to eq(3000)
    expect(changed.rows).to eq(400)
  end

  it 'squares the image when given only one argument' do
    image = described_class.new(20, 20)

    changed = image.resize_to_fill(100)
    expect(changed.columns).to eq(100)
    expect(changed.rows).to eq(100)
  end
end
