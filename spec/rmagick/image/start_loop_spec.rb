RSpec.describe Magick::Image, '#start_loop' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.start_loop }.not_to raise_error
    expect(image.start_loop).to be(false)
    expect { image.start_loop = true }.not_to raise_error
    expect(image.start_loop).to be(true)
  end
end
