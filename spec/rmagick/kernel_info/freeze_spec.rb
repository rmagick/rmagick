# frozen_string_literal: true

RSpec.describe Magick::KernelInfo, '#freeze' do
  it 'raises RuntimeError while a call changes the kernel' do
    kernel = described_class.new('3x3: 1,1,1,1,1,1,1,1,1')
    error = nil
    freeze = lambda do
      kernel.freeze
    rescue RuntimeError => e
      error = e.message
    end

    during_call(freeze) { kernel.scale(2, Magick::NoValue) }

    expect(error).to eq('object is in use by another fiber')
    expect(kernel).not_to be_frozen
  end

  it 'freezes a kernel that no call uses' do
    kernel = described_class.new('3x3: 1,1,1,1,1,1,1,1,1')

    expect(kernel.freeze).to be(kernel)
    expect(kernel).to be_frozen
  end
end
