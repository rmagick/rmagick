RSpec.describe Magick::Draw, '#gravity=' do
  before do
    @draw = described_class.new
  end

  it 'works' do
    Magick::GravityType.values do |gravity|
      expect { @draw.gravity = gravity }.not_to raise_error
    end

    expect { @draw.gravity = 2 }.to raise_error(TypeError)
  end
end
