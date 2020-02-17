RSpec.describe Magick::Draw, '#initialize' do
  it 'works' do
    yield_obj = nil

    described_class.new do |option|
      yield_obj = option
    end
    expect(yield_obj).to be_instance_of(Magick::Image::DrawOptions)
  end
end
