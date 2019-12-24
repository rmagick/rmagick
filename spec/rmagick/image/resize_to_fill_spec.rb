RSpec.describe Magick::Image, '#resize_to_fill' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'does not change image when using the same dimensions' do
    changed = @img.resize_to_fill(@img.columns, @img.rows)
    expect(changed.columns).to eq(@img.columns)
    expect(changed.rows).to eq(@img.rows)
    expect(@img).not_to be(changed)
  end

  it 'resizes to the given dimensions' do
    @img = Magick::Image.new(200, 250)
    @img.resize_to_fill!(100, 100)
    expect(@img.columns).to eq(100)
    expect(@img.rows).to eq(100)

    @img = Magick::Image.new(200, 250)
    changed = @img.resize_to_fill(300, 100)
    expect(changed.columns).to eq(300)
    expect(changed.rows).to eq(100)

    @img = Magick::Image.new(200, 250)
    changed = @img.resize_to_fill(100, 300)
    expect(changed.columns).to eq(100)
    expect(changed.rows).to eq(300)

    @img = Magick::Image.new(200, 250)
    changed = @img.resize_to_fill(300, 350)
    expect(changed.columns).to eq(300)
    expect(changed.rows).to eq(350)

    @img = Magick::Image.new(200, 250)
    changed = @img.resize_to_fill(20, 400)
    expect(changed.columns).to eq(20)
    expect(changed.rows).to eq(400)

    @img = Magick::Image.new(200, 250)
    changed = @img.resize_to_fill(3000, 400)
    expect(changed.columns).to eq(3000)
    expect(changed.rows).to eq(400)
  end

  it 'squares the image when given only one argument' do
    changed = @img.resize_to_fill(100)
    expect(changed.columns).to eq(100)
    expect(changed.rows).to eq(100)
  end
end
