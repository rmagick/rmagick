# frozen_string_literal: true

RSpec.describe Magick::KernelInfo, '#initialize' do
  it 'works' do
    Magick::KernelInfoType.values do |kernel|
      next if [Magick::UserDefinedKernel, Magick::UndefinedKernel].include?(kernel)

      k = kernel.to_s.sub('Kernel', '')

      expect(described_class.new(k)).to be_instance_of(described_class)
    end
    expect { described_class.new('') }.to raise_error(RuntimeError)
    expect { described_class.new(42) }.to raise_error(TypeError)
  end

  it 'replaces the kernel when it is called again' do
    image = Magick::Image.new(5, 5) { |options| options.background_color = 'gray25' }
    kernel = described_class.new('3x3: 0,0,0 0,1,0 0,0,0')
    kernel.__send__(:initialize, '3x3: 0,0,0 0,2,0 0,0,0')

    result = image.morphology(Magick::ConvolveMorphology, 1, kernel)
    expect(result.pixel_color(2, 2).red).to be_within(2).of(image.pixel_color(2, 2).red * 2)
  end

  it 'raises FrozenError for a frozen kernel' do
    kernel = described_class.new('Diamond').freeze

    expect { kernel.__send__(:initialize, 'Square') }.to raise_error(FrozenError)
  end

  it 'rejects a kernel string that names a file with @' do
    Tempfile.create(['kernel', '.txt']) do |file|
      file.write('3x3: 0,0,0 0,1,0 0,0,0')
      file.flush

      expect { described_class.new("@#{file.path}") }.to raise_error(ArgumentError, /must not name a file/)
      expect { described_class.new("  @#{file.path}") }.to raise_error(ArgumentError, /must not name a file/)
    end
  end
end
