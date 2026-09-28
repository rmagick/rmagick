# frozen_string_literal: true

RSpec.describe Magick::Pixel, '.new' do
  it 'is opaque by default' do
    expect(described_class.new(1, 2, 3).alpha).to eq(Magick::QuantumRange)
  end

  it 'treats the fourth argument as opacity' do
    expect(described_class.new(0, 0, 0, 0).alpha).to eq(Magick::QuantumRange)
    expect(described_class.new(0, 0, 0, Magick::QuantumRange).alpha).to eq(0)
    expect(described_class.new(1, 2, 3, 100).alpha).to eq(Magick::QuantumRange - 100)
  end

  it 'ignores a nil opacity' do
    expect(described_class.new(0, 0, 0, nil).alpha).to eq(Magick::QuantumRange)
  end
end
