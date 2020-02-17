RSpec.describe Magick::Image, '#interlace' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.interlace }.not_to raise_error
    expect(image.interlace).to be_instance_of(Magick::InterlaceType)
    expect(image.interlace).to eq(Magick::NoInterlace)
    expect { image.interlace = Magick::LineInterlace }.not_to raise_error
    expect(image.interlace).to eq(Magick::LineInterlace)

    Magick::InterlaceType.values do |interlace|
      expect { image.interlace = interlace }.not_to raise_error
    end
    expect { image.interlace = 2 }.to raise_error(TypeError)
  end
end
