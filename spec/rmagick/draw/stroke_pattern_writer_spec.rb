RSpec.describe Magick::Draw, '#stroke_pattern' do
  it 'accepts an Image argument' do
    draw = described_class.new
    img = Magick::Image.new(20, 20)

    expect { draw.stroke_pattern = img }.not_to raise_error
  end

  it 'accepts an ImageList argument' do
    draw = described_class.new
    img = Magick::Image.new(20, 20)
    ilist = Magick::ImageList.new
    ilist << img

    expect { draw.stroke_pattern = ilist }.not_to raise_error
  end

  it 'does not accept arbitrary arguments' do
    draw = described_class.new

    expect { draw.stroke_pattern = 1 }.to raise_error(NoMethodError)
  end

  it 'works' do
    draw = described_class.new

    expect { draw.stroke_pattern = nil }.not_to raise_error
    expect do
      img1 = Magick::Image.new(10, 10)
      img2 = Magick::Image.new(20, 20)

      draw.stroke_pattern = img1
      draw.stroke_pattern = img2
    end.not_to raise_error

    expect { draw.stroke_pattern = 'x' }.to raise_error(NoMethodError)
  end
end
