RSpec.describe Magick::Image, '#view' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.view(0, 0, 5, 5)
    expect(res).to be_instance_of(Magick::Image::View)

    image.view(0, 0, 5, 5) { |v| expect(v).to be_instance_of(Magick::Image::View) }

    expect { image.view(-1, 0, 5, 5) }.to raise_error(RangeError)
    expect { image.view(0, -1, 5, 5) }.to raise_error(RangeError)
    expect { image.view(1, 0, image.columns, 5) }.to raise_error(RangeError)
    expect { image.view(0, 1, 5, image.rows) }.to raise_error(RangeError)
    expect { image.view(0, 0, 0, 1) }.to raise_error(ArgumentError)
    expect { image.view(0, 0, 1, 0) }.to raise_error(ArgumentError)
  end
end
