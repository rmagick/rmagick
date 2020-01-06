RSpec.describe Magick::Image, '#orientation' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.orientation }.not_to raise_error
    expect(img.orientation).to be_instance_of(Magick::OrientationType)
    expect(img.orientation).to eq(Magick::UndefinedOrientation)
    expect { img.orientation = Magick::TopLeftOrientation }.not_to raise_error
    expect(img.orientation).to eq(Magick::TopLeftOrientation)

    Magick::OrientationType.values do |orientation|
      expect { img.orientation = orientation }.not_to raise_error
    end
    expect { img.orientation = 2 }.to raise_error(TypeError)
  end
end
