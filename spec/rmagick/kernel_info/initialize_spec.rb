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
end
