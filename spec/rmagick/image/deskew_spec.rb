# frozen_string_literal: true

RSpec.describe Magick::Image, '#deskew' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.deskew
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.deskew(0.10) }.not_to raise_error
    expect { image.deskew('95%') }.not_to raise_error
    expect { image.deskew('x') }.to raise_error(ArgumentError)
    expect { image.deskew(0.40, 'x') }.to raise_error(TypeError)
    expect { image.deskew(0.40, 20, [1]) }.to raise_error(ArgumentError)
  end

  def skewed_image(background, foreground)
    image = described_class.new(200, 200) { |options| options.background_color = background }
    draw = Magick::Draw.new
    draw.fill(foreground)
    draw.polygon(40, 60, 160, 45, 165, 140, 45, 155)
    draw.draw(image)
    image.background_color = 'white'
    image
  end

  it 'auto-crops with the average color of a border of auto_crop_width pixels as the background' do
    image = skewed_image('black', 'white')

    plain = image.deskew(0.40)
    cropped = image.deskew(0.40, 20)

    expect(cropped.columns).to be < plain.columns * 0.7
    expect(cropped.rows).to be < plain.rows * 0.7
  end

  it 'auto-crops with the background color of the image when auto_crop_width is true' do
    image = skewed_image('white', 'black')

    plain = image.deskew(0.40)
    cropped = image.deskew(0.40, true)

    expect(cropped.columns).to be < plain.columns * 0.7
    expect(cropped.rows).to be < plain.rows * 0.7
  end

  it 'does not auto-crop when auto_crop_width is false or nil' do
    image = skewed_image('white', 'black')
    plain = image.deskew(0.40)

    [false, nil].each do |auto_crop_width|
      result = image.deskew(0.40, auto_crop_width)

      expect([result.columns, result.rows]).to eq([plain.columns, plain.rows])
    end
  end
end
