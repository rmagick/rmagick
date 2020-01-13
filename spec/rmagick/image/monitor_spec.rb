RSpec.describe Magick::Image, '#monitor' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.monitor }.to raise_error(NoMethodError)
    monitor = proc { |name, _q, _s| puts name }
    expect { @img.monitor = monitor }.not_to raise_error
    expect { @img.monitor = nil }.not_to raise_error
  end
end
