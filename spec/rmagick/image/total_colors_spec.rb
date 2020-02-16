RSpec.describe Magick::Image, '#total_colors' do
  it 'works' do
    hat = described_class.read(FLOWER_HAT).first

    expect { hat.total_colors }.not_to raise_error
    expect(hat.total_colors).to be_kind_of(Integer)
    expect { hat.total_colors = 2 }.to raise_error(NoMethodError)
  end
end
