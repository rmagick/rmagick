RSpec.describe Magick::Image, '#view' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.view(0, 0, 5, 5)
      expect(res).to be_instance_of(Magick::Image::View)
    end.not_to raise_error
    expect do
      img.view(0, 0, 5, 5) { |v| expect(v).to be_instance_of(Magick::Image::View) }
    end.not_to raise_error
    expect { img.view(-1, 0, 5, 5) }.to raise_error(RangeError)
    expect { img.view(0, -1, 5, 5) }.to raise_error(RangeError)
    expect { img.view(1, 0, img.columns, 5) }.to raise_error(RangeError)
    expect { img.view(0, 1, 5, img.rows) }.to raise_error(RangeError)
    expect { img.view(0, 0, 0, 1) }.to raise_error(ArgumentError)
    expect { img.view(0, 0, 1, 0) }.to raise_error(ArgumentError)
  end
end
