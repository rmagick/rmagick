# frozen_string_literal: true

RSpec.describe Magick::KernelInfo, '#dup' do
  it 'returns an unfrozen copy' do
    kernel = described_class.new('Octagon').freeze
    copy = kernel.dup

    expect(copy).to be_instance_of(described_class)
    expect(copy).not_to be(kernel)
    expect(copy).not_to be_frozen
    expect(copy.scale(1.0, Magick::NormalizeValue)).to be(nil)
  end
end
