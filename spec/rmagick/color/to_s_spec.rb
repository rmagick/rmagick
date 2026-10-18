# frozen_string_literal: true

describe Magick::Color, '#to_s' do
  it 'works' do
    color = Magick.colors[0]
    expect(color).to be_instance_of(described_class)
    expect(color.to_s).to match(/name=.+, compliance=.+, color.red=.+, color.green=.+, color.blue=.+, color.alpha=.+/)
  end

  it 'shows an empty name when the name is nil' do
    color = described_class.new(nil, Magick::SVGCompliance, nil)

    expect(color.to_s).to start_with('name=, compliance=SVGCompliance, ')
  end

  it 'raises TypeError for a member of the wrong type' do
    color = described_class.new('red', :svg, nil)

    expect { color.to_s }.to raise_error(TypeError)
  end
end
