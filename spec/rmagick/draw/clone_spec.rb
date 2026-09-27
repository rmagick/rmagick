# frozen_string_literal: true

RSpec.describe Magick::Draw, '#clone' do
  it 'works' do
    draw = described_class.new

    draw.freeze
    clone = draw.clone
    expect(clone).to be_instance_of(described_class)
  end

  it 'accepts the freeze keyword as Object#clone does' do
    object = described_class.new.freeze

    expect(object.clone(freeze: false)).not_to be_frozen
    expect(object.clone(freeze: true)).to be_frozen
  end
end
