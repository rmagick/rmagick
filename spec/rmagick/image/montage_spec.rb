RSpec.describe Magick::Image, '#montage' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.montage }.not_to raise_error
    expect(@img.montage).to be(nil)
  end
end
