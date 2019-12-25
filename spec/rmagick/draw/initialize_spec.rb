RSpec.describe Magick::Draw, '#initialize' do
  before do
    @draw = Magick::Draw.new
  end

  it 'works' do
    expect do
      yield_obj = nil

      Magick::Draw.new do |option|
        yield_obj = option
      end
      expect(yield_obj).to be_instance_of(Magick::Image::DrawOptions)
    end.not_to raise_error
  end
end
