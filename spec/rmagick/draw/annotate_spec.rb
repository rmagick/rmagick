RSpec.describe Magick::Draw, '#annotate' do
  it 'works' do
    draw = described_class.new

    image = Magick::Image.new(10, 10)
    draw.annotate(image, 0, 0, 0, 20, 'Hello world')

    yield_obj = nil
    draw.annotate(image, 100, 100, 20, 20, 'Hello world 2') do |draw2|
      yield_obj = draw2
    end
    expect(yield_obj).to be_instance_of(described_class)

    expect do
      image = Magick::Image.new(10, 10)
      draw.annotate(image, 0, 0, 0, 20, nil)
    end.to raise_error(TypeError)

    expect { draw.annotate('x', 0, 0, 0, 20, 'Hello world') }.to raise_error(NoMethodError)
  end

  it 'does not trigger a buffer overflow' do
    draw = described_class.new

    expect do
      if 1.size == 8
        # 64-bit environment can use larger value for Integer and it can cause
        # a stack buffer overflow.
        image = Magick::Image.new(10, 10)
        draw.annotate(image, 2**63, 2**63, 2**62, 2**62, 'Hello world')
      end
    end.not_to raise_error
  end
end
