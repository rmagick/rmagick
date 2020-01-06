RSpec.describe Magick::Image, '#histogram?' do
  it 'works' do
    img = described_class.new(20, 20)

    expect { img.histogram? }.not_to raise_error
    expect(img.histogram?).to be(true)
  end
end
