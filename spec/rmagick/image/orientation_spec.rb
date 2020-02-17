RSpec.describe Magick::Image, '#orientation' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.orientation }.not_to raise_error
    expect(image.orientation).to be_instance_of(Magick::OrientationType)
    expect(image.orientation).to eq(Magick::UndefinedOrientation)
    expect { image.orientation = Magick::TopLeftOrientation }.not_to raise_error
    expect(image.orientation).to eq(Magick::TopLeftOrientation)

    Magick::OrientationType.values do |orientation|
      expect { image.orientation = orientation }.not_to raise_error
    end
    expect { image.orientation = 2 }.to raise_error(TypeError)
  end
end
