# frozen_string_literal: true

RSpec.describe Magick::KernelInfo, '#unity_add' do
  it 'works' do
    kernel = described_class.new('Octagon')

    expect(kernel.unity_add(1.0)).to be(nil)
    expect(kernel.unity_add(12)).to be(nil)
    expect { kernel.unity_add('x') }.to raise_error(TypeError)
  end

  it 'raises FrozenError for a frozen kernel' do
    kernel = described_class.new('Octagon').freeze

    expect { kernel.unity_add(1.0) }.to raise_error(FrozenError)
  end

  it 'changes the new kernel when converting the argument replaces the kernel' do
    image = Magick::Image.new(5, 5) { |options| options.background_color = 'gray25' }
    kernel = described_class.new('3x3: 0,0,0 0,1,0 0,0,0')
    arg = Struct.new(:kernel) do
      def to_f
        kernel.__send__(:initialize, '3x3: 0,0,0 0,2,0 0,0,0') && 1.0
      end
    end.new(kernel)

    kernel.unity_add(arg)

    result = image.morphology(Magick::ConvolveMorphology, 1, kernel)
    expect(result.pixel_color(2, 2).red).to be_within(2).of(image.pixel_color(2, 2).red * 3)
  end
end
