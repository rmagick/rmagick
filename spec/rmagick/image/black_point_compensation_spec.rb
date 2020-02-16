RSpec.describe Magick::Image, '#black_point_compensation' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.black_point_compensation = true }.not_to raise_error
    expect(img.black_point_compensation).to be(true)
    expect { img.black_point_compensation = false }.not_to raise_error
    expect(img.black_point_compensation).to be(false)
  end
end
