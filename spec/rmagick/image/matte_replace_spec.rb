RSpec.describe Magick::Image, '#matte_replace' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    expect do
      res = @img.matte_replace(@img.columns / 2, @img.rows / 2)
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(@img)
    end.not_to raise_error
  end
end
