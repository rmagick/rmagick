RSpec.describe Magick::Image, '#filename' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.filename }.not_to raise_error
    expect(@img.filename).to eq('')
    expect { @img.filename = 'xxx' }.to raise_error(NoMethodError)
  end
end
