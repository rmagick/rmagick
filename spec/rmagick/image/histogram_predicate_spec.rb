RSpec.describe Magick::Image, '#histogram?' do
  it 'works' do
    image = described_class.new(20, 20)

    expect { image.histogram? }.not_to raise_error
    expect(image.histogram?).to be(true)
  end
end
