RSpec.describe Magick::Draw, '#decorate=' do
  it 'works' do
    draw = described_class.new

    Magick::DecorationType.values do |decoration|
      expect { draw.decorate = decoration }.not_to raise_error
    end
  end
end
