RSpec.describe Magick::Draw, '#clone' do
  before do
    @draw = Magick::Draw.new
  end

  it 'works' do
    @draw.freeze
    clone = @draw.clone
    expect(clone).to be_instance_of(Magick::Draw)
  end
end
