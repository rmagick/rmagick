RSpec.describe Magick::Image, '#black_point_compensation' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.black_point_compensation = true }.not_to raise_error
    expect(@img.black_point_compensation).to be(true)
    expect { @img.black_point_compensation = false }.not_to raise_error
    expect(@img.black_point_compensation).to be(false)
  end
end
