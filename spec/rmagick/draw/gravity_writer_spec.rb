RSpec.describe Magick::Draw, '#gravity=' do
  it 'works' do
    draw = described_class.new

    Magick::GravityType.values do |gravity|
      expect { draw.gravity = gravity }.not_to raise_error
    end

    expect { draw.gravity = 2 }.to raise_error(TypeError)
  end
end
