RSpec.describe Magick::Image, '#watermark' do
  it 'works' do
    img = described_class.new(20, 20)
    mark = described_class.new(5, 5)
    mark_list = Magick::ImageList.new
    mark_list << mark.copy

    expect { img.watermark(mark) }.not_to raise_error
    expect { img.watermark(mark_list) }.not_to raise_error
    expect { img.watermark(mark, 0.50) }.not_to raise_error
    expect { img.watermark(mark, '50%') }.not_to raise_error
    expect { img.watermark(mark, 0.50, 0.50) }.not_to raise_error
    expect { img.watermark(mark, 0.50, '50%') }.not_to raise_error
    expect { img.watermark(mark, 0.50, 0.50, 10) }.not_to raise_error
    expect { img.watermark(mark, 0.50, 0.50, 10, 10) }.not_to raise_error
    expect { img.watermark(mark, 0.50, 0.50, Magick::NorthEastGravity) }.not_to raise_error
    expect { img.watermark(mark, 0.50, 0.50, Magick::NorthEastGravity, 10) }.not_to raise_error
    expect { img.watermark(mark, 0.50, 0.50, Magick::NorthEastGravity, 10, 10) }.not_to raise_error

    expect { img.watermark }.to raise_error(ArgumentError)
    expect { img.watermark(mark, 'x') }.to raise_error(ArgumentError)
    expect { img.watermark(mark, 0.50, 'x') }.to raise_error(ArgumentError)
    expect { img.watermark(mark, 0.50, '1500%') }.to raise_error(ArgumentError)
    expect { img.watermark(mark, 0.50, 0.50, 'x') }.to raise_error(TypeError)
    expect { img.watermark(mark, 0.50, 0.50, Magick::NorthEastGravity, 'x') }.to raise_error(TypeError)
    expect { img.watermark(mark, 0.50, 0.50, Magick::NorthEastGravity, 10, 'x') }.to raise_error(TypeError)

    mark.destroy!
    expect { img.watermark(mark) }.to raise_error(Magick::DestroyedImageError)
  end
end
