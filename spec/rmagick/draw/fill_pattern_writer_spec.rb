# frozen_string_literal: true

RSpec.describe Magick::Draw, '#fill_pattern' do
  it 'accepts an Image argument' do
    draw = described_class.new
    image = Magick::Image.new(20, 20)

    expect { draw.fill_pattern = image }.not_to raise_error
  end

  it 'accepts an ImageList argument' do
    draw = described_class.new
    image = Magick::Image.new(20, 20)
    image_list = Magick::ImageList.new
    image_list << image

    expect { draw.fill_pattern = image_list }.not_to raise_error
  end

  it 'does not accept arbitrary arguments' do
    draw = described_class.new

    expect { draw.fill_pattern = 1 }.to raise_error(NoMethodError)
  end

  it 'works' do
    draw = described_class.new

    expect { draw.fill_pattern = nil }.not_to raise_error
    expect do
      image1 = Magick::Image.new(10, 10)
      image2 = Magick::Image.new(20, 20)

      draw.fill_pattern = image1
      draw.fill_pattern = image2
    end.not_to raise_error

    expect { draw.fill_pattern = 'x' }.to raise_error(NoMethodError)
  end

  it "keeps the pattern when the new one is destroyed" do
    draw = described_class.new
    pattern = Magick::Image.new(4, 4)
    pattern.format = "MIFF"
    draw.fill_pattern = pattern
    destroyed = Magick::Image.new(2, 2)
    destroyed.destroy!

    expect { draw.fill_pattern = destroyed }.to raise_error(Magick::DestroyedImageError)
    expect(draw.marshal_dump[:fill_pattern]).to be_kind_of(String)
  end
end
