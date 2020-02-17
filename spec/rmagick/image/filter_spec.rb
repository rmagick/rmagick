RSpec.describe Magick::Image, '#filter' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.filter }.not_to raise_error
    expect(image.filter).to be_instance_of(Magick::FilterType)
    expect(image.filter).to eq(Magick::UndefinedFilter)
    expect { image.filter = Magick::PointFilter }.not_to raise_error
    expect(image.filter).to eq(Magick::PointFilter)

    Magick::FilterType.values do |filter|
      expect { image.filter = filter }.not_to raise_error
    end
    expect { image.filter = 2 }.to raise_error(TypeError)
  end
end
