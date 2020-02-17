RSpec.describe Magick::Image, '#monitor' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.monitor }.to raise_error(NoMethodError)
    monitor = proc { |name, _q, _s| puts name }
    expect { image.monitor = monitor }.not_to raise_error
    expect { image.monitor = nil }.not_to raise_error
  end
end
