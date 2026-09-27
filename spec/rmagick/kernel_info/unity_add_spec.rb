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
end
