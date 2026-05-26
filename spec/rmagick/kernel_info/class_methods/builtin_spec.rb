# frozen_string_literal: true

RSpec.describe Magick::KernelInfo, '.builtin' do
  it 'works' do
    expect(described_class.builtin(Magick::UnityKernel, '')).to be_instance_of(described_class)
    expect(described_class.builtin(Magick::GaussianKernel, '10,5')).to be_instance_of(described_class)
    expect(described_class.builtin(Magick::LoGKernel, '10,5')).to be_instance_of(described_class)
    expect(described_class.builtin(Magick::DoGKernel, '10,5')).to be_instance_of(described_class)
    expect(described_class.builtin(Magick::BlurKernel, '10,5')).to be_instance_of(described_class)
    expect(described_class.builtin(Magick::CometKernel, '10,5')).to be_instance_of(described_class)
    expect { described_class.builtin(Magick::GaussianKernel, 'invalid') }.to raise_error(ArgumentError)
  end
end
