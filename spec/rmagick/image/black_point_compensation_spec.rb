RSpec.describe Magick::Image, '#black_point_compensation' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.black_point_compensation = true }.not_to raise_error
    expect(image.black_point_compensation).to be(true)
    expect { image.black_point_compensation = false }.not_to raise_error
    expect(image.black_point_compensation).to be(false)
  end
end
