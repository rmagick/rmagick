RSpec.describe Magick::Image, '#base_columns' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.base_columns }.not_to raise_error
    expect(@img.base_columns).to eq(0)
    expect { @img.base_columns = 1 }.to raise_error(NoMethodError)
  end
end
