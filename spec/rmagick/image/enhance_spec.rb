RSpec.describe Magick::Image, '#enhance' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    expect do
      res = @img.enhance
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(@img)
    end.not_to raise_error
  end
end
