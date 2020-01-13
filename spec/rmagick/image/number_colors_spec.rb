RSpec.describe Magick::Image, '#number_colors' do
  before do
    @hat = described_class.read(FLOWER_HAT).first
  end

  it 'works' do
    expect { @hat.number_colors }.not_to raise_error
    expect(@hat.number_colors).to be_kind_of(Integer)
    expect { @hat.number_colors = 2 }.to raise_error(NoMethodError)
  end
end
