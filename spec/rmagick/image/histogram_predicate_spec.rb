RSpec.describe Magick::Image, '#histogram?' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    expect { @img.histogram? }.not_to raise_error
    expect(@img.histogram?).to be(true)
  end
end
