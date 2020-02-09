RSpec.describe Magick::Image, '#wet_floor' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect(@img.wet_floor).to be_instance_of(described_class)
    expect { @img.wet_floor(0.0) }.not_to raise_error
    expect { @img.wet_floor(0.5) }.not_to raise_error
    expect { @img.wet_floor(0.5, 10) }.not_to raise_error
    expect { @img.wet_floor(0.5, 0.0) }.not_to raise_error

    expect { @img.wet_floor(2.0) }.to raise_error(ArgumentError)
    expect { @img.wet_floor(-2.0) }.to raise_error(ArgumentError)
    expect { @img.wet_floor(0.5, -1.0) }.to raise_error(ArgumentError)
    expect { @img.wet_floor(0.5, 10, 0.5) }.to raise_error(ArgumentError)
  end
end
