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
end
