# frozen_string_literal: true

RSpec.describe Magick::KernelInfo, '#scale' do
  it 'works' do
    kernel = described_class.new('Octagon')

    Magick::GeometryFlags.values do |flag|
      expect(kernel.scale(1.0, flag)).to be(nil)
      expect(kernel.scale(42, flag)).to be(nil)
    end
    expect { kernel.scale(42, 'x') }.to raise_error(TypeError)
    expect { kernel.scale(42, Magick::BoldWeight) }.to raise_error(TypeError)
  end

  it 'raises FrozenError for a frozen kernel' do
    kernel = described_class.new('Octagon').freeze

    expect { kernel.scale(1.0, Magick::NormalizeValue) }.to raise_error(FrozenError)
  end

  it 'changes the new kernel when converting the argument replaces the kernel' do
    image = Magick::Image.new(5, 5) { |options| options.background_color = 'gray25' }
    kernel = described_class.new('3x3: 0,0,0 0,1,0 0,0,0')
    arg = Struct.new(:kernel) do
      def to_f
        kernel.__send__(:initialize, '3x3: 0,0,0 0,2,0 0,0,0') && 1.5
      end
    end.new(kernel)

    kernel.scale(arg, Magick::NoValue)

    result = image.morphology(Magick::ConvolveMorphology, 1, kernel)
    expect(result.pixel_color(2, 2).red).to be_within(2).of(image.pixel_color(2, 2).red * 3)
  end
end
