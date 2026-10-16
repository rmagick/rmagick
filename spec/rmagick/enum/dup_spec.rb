# frozen_string_literal: true

RSpec.describe Magick::Enum, '#dup' do
  it 'returns itself' do
    expect(Magick::OverCompositeOp.dup).to be(Magick::OverCompositeOp)
    expect(Magick::PercentGeometry.dup).to be(Magick::PercentGeometry)
  end

  it 'returns itself from clone' do
    expect(Magick::OverCompositeOp.clone).to be(Magick::OverCompositeOp)
    expect(Magick::OverCompositeOp.clone(freeze: true)).to be(Magick::OverCompositeOp)
  end

  it 'raises ArgumentError when clone is asked to unfreeze' do
    expect { Magick::OverCompositeOp.clone(freeze: false) }.to raise_error(ArgumentError, "can't unfreeze Magick::CompositeOperator")
  end
end
