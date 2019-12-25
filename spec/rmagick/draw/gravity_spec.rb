RSpec.describe Magick::Draw, '#gravity' do
  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    Magick::GravityType.values do |gravity|
      next if [Magick::UndefinedGravity].include?(gravity)

      draw = Magick::Draw.new
      draw.gravity(gravity)
      draw.circle(10, '20.5', 30, 40.5)
      expect { draw.draw(@img) }.not_to raise_error
    end

    expect { @draw.gravity('xxx') }.to raise_error(ArgumentError)
  end
end
