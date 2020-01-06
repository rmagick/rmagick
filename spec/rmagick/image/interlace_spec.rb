RSpec.describe Magick::Image, '#interlace' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.interlace }.not_to raise_error
    expect(img.interlace).to be_instance_of(Magick::InterlaceType)
    expect(img.interlace).to eq(Magick::NoInterlace)
    expect { img.interlace = Magick::LineInterlace }.not_to raise_error
    expect(img.interlace).to eq(Magick::LineInterlace)

    Magick::InterlaceType.values do |interlace|
      expect { img.interlace = interlace }.not_to raise_error
    end
    expect { img.interlace = 2 }.to raise_error(TypeError)
  end
end
