RSpec.describe Magick::Image, '#gravity' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect(@img.gravity).to be_instance_of(Magick::GravityType)

    Magick::GravityType.values do |gravity|
      expect { @img.gravity = gravity }.not_to raise_error
    end
    expect { @img.gravity = nil }.to raise_error(TypeError)
    expect { @img.gravity = Magick::PointFilter }.to raise_error(TypeError)
  end
end
