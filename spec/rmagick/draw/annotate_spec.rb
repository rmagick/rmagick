RSpec.describe Magick::Draw, '#annotate' do
  before do
    @draw = described_class.new
  end

  it 'works' do
    expect do
      img = Magick::Image.new(10, 10)
      @draw.annotate(img, 0, 0, 0, 20, 'Hello world')

      yield_obj = nil
      @draw.annotate(img, 100, 100, 20, 20, 'Hello world 2') do |draw|
        yield_obj = draw
      end
      expect(yield_obj).to be_instance_of(described_class)
    end.not_to raise_error

    expect do
      img = Magick::Image.new(10, 10)
      @draw.annotate(img, 0, 0, 0, 20, nil)
    end.to raise_error(TypeError)

    expect { @draw.annotate('x', 0, 0, 0, 20, 'Hello world') }.to raise_error(NoMethodError)
  end

  it 'does not trigger a buffer overflow' do
    expect do
      if 1.size == 8
        # 64-bit environment can use larger value for Integer and it can cause
        # a stack buffer overflow.
        img = Magick::Image.new(10, 10)
        @draw.annotate(img, 2**63, 2**63, 2**62, 2**62, 'Hello world')
      end
    end.not_to raise_error
  end
end
