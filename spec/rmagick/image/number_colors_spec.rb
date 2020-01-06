RSpec.describe Magick::Image, '#number_colors' do
  it 'works' do
    hat = described_class.read(FLOWER_HAT).first

    expect { hat.number_colors }.not_to raise_error
    expect(hat.number_colors).to be_kind_of(Integer)
    expect { hat.number_colors = 2 }.to raise_error(NoMethodError)
  end
end
