# frozen_string_literal: true

RSpec.describe Magick::KernelInfo, '#clone' do
  it 'works' do
    kernel = described_class.new('Octagon')

    expect(kernel.clone).to be_instance_of(described_class)
    expect(kernel.clone).not_to be(kernel)
  end

  it 'keeps the frozen state' do
    kernel = described_class.new('Octagon')

    expect(kernel.clone).not_to be_frozen
    expect(kernel.freeze.clone).to be_frozen
  end
end
