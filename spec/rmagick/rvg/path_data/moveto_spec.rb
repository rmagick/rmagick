# frozen_string_literal: true

describe Magick::RVG::PathData, '#moveto' do
  it 'works' do
    pd = described_class.new

    expect { pd.moveto(true, 0, 0) }.not_to raise_error
  end
end
