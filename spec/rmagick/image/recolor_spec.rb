RSpec.describe Magick::Image, '#recolor' do
  it 'works' do
    image = described_class.new(20, 20)

    expect { image.recolor([1, 1, 2, 1]) }.not_to raise_error
    expect { image.recolor('x') }.to raise_error(TypeError)
    expect { image.recolor([1, 1, 'x', 1]) }.to raise_error(TypeError)
  end
end
