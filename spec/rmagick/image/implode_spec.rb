RSpec.describe Magick::Image, '#implode' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    expect do
      res = @img.implode(0.5)
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.implode(0.5, 0.5) }.to raise_error(ArgumentError)
  end
end
