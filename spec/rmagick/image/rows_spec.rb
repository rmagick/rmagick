RSpec.describe Magick::Image, '#rows' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.rows }.not_to raise_error
    expect(@img.rows).to eq(100)
    expect { @img.rows = 2 }.to raise_error(NoMethodError)
  end
end
