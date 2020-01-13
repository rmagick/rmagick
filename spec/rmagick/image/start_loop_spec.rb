RSpec.describe Magick::Image, '#start_loop' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.start_loop }.not_to raise_error
    expect(@img.start_loop).to be(false)
    expect { @img.start_loop = true }.not_to raise_error
    expect(@img.start_loop).to be(true)
  end
end
