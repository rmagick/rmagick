RSpec.describe Magick::Image, '#recolor' do
  it 'works' do
    img = described_class.new(20, 20)

    expect { img.recolor([1, 1, 2, 1]) }.not_to raise_error
    expect { img.recolor('x') }.to raise_error(TypeError)
    expect { img.recolor([1, 1, 'x', 1]) }.to raise_error(TypeError)
  end
end
