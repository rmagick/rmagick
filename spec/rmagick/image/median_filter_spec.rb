RSpec.describe Magick::Image, '#median_filter' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      res = @img.median_filter
      expect(res).to be_instance_of(Magick::Image)
      expect(res).not_to be(@img)
    end.not_to raise_error
    expect { @img.median_filter(0.5) }.not_to raise_error
    expect { @img.median_filter(0.5, 'x') }.to raise_error(ArgumentError)
    expect { @img.median_filter('x') }.to raise_error(TypeError)
  end
end
