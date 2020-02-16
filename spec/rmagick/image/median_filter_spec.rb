RSpec.describe Magick::Image, '#median_filter' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.median_filter
      expect(res).to be_instance_of(described_class)
      expect(res).not_to be(img)
    end.not_to raise_error
    expect { img.median_filter(0.5) }.not_to raise_error
    expect { img.median_filter(0.5, 'x') }.to raise_error(ArgumentError)
    expect { img.median_filter('x') }.to raise_error(TypeError)
  end
end
