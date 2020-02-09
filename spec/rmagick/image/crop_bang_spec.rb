RSpec.describe Magick::Image, '#crop!' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    expect do
      res = @img.crop!(0, 0, @img.columns / 2, @img.rows / 2)
      expect(res).to be(@img)
    end.not_to raise_error
  end
end
