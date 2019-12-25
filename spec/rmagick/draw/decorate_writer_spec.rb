RSpec.describe Magick::Draw, '#decorate=' do
  before do
    @draw = Magick::Draw.new
  end

  it 'works' do
    Magick::DecorationType.values do |decoration|
      expect { @draw.decorate = decoration }.not_to raise_error
    end
  end
end
