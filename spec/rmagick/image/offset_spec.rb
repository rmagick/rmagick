RSpec.describe Magick::Image, '#offset' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.offset }.not_to raise_error
    expect(@img.offset).to eq(0)
    expect { @img.offset = 10 }.not_to raise_error
    expect(@img.offset).to eq(10)
    expect { @img.offset = 'x' }.to raise_error(TypeError)
  end
end
