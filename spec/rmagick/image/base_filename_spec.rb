RSpec.describe Magick::Image, '#base_filename' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.base_filename }.not_to raise_error
    expect(@img.base_filename).to eq('')
    expect { @img.base_filename = 'xxx' }.to raise_error(NoMethodError)
  end
end
