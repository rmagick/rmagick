RSpec.describe Magick::Image, '#posterize' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    expect do
      res = @img.posterize
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.posterize(5) }.not_to raise_error
    expect { @img.posterize(5, true) }.not_to raise_error
    expect { @img.posterize(5, true, 'x') }.to raise_error(ArgumentError)
  end
end
