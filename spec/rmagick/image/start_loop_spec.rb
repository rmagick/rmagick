RSpec.describe Magick::Image, '#start_loop' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.start_loop }.not_to raise_error
    expect(img.start_loop).to be(false)
    expect { img.start_loop = true }.not_to raise_error
    expect(img.start_loop).to be(true)
  end
end
