RSpec.describe Magick::Image, '#spread' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.spread
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error
    expect { img.spread(3.0) }.not_to raise_error
    expect { img.spread(3.0, 2) }.to raise_error(ArgumentError)
    expect { img.spread('x') }.to raise_error(TypeError)
  end
end
