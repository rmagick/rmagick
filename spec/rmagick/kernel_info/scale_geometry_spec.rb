# frozen_string_literal: true

RSpec.describe Magick::KernelInfo, '#scale_geometry' do
  it 'works' do
    kernel = described_class.new('Octagon')

    expect(kernel.scale_geometry('-set option:convolve:scale 1.0')).to be(nil)
    expect { kernel.scale_geometry(42) }.to raise_error(TypeError)
  end

  it 'raises FrozenError for a frozen kernel' do
    kernel = described_class.new('Octagon').freeze

    expect { kernel.scale_geometry('1!') }.to raise_error(FrozenError)
  end

  it 'changes the new kernel when converting the argument replaces the kernel' do
    image = Magick::Image.new(5, 5) { |options| options.background_color = 'gray25' }
    kernel = described_class.new('3x3: 0,0,0 0,1,0 0,0,0')
    arg = Struct.new(:kernel) do
      def to_str
        kernel.__send__(:initialize, '3x3: 0,0,0 0,2,0 0,0,0') && '1.5'
      end
    end.new(kernel)

    kernel.scale_geometry(arg)

    result = image.morphology(Magick::ConvolveMorphology, 1, kernel)
    expect(result.pixel_color(2, 2).red).to be_within(2).of(image.pixel_color(2, 2).red * 3)
  end
end
