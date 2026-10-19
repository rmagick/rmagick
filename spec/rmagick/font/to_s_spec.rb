# frozen_string_literal: true

describe Magick::Font, '#to_s' do
  it 'works' do
    font = Magick.fonts[0]
    expect(font.to_s).to start_with("name=#{font.name}, description=#{font.description}, family=#{font.family}, ")
    expect(font.to_s).to match(/, style=.+, stretch=.+, weight=.+, encoding=.*, foundry=.*, format=.*$/)
  end

  it 'shows each member' do
    font = described_class.new('a', 'b', 'c', Magick::ItalicStyle, Magick::CondensedStretch, 400, 'e', 'f', 'g')

    expect(font.to_s).to eq('name=a, description=b, family=c, style=ItalicStyle, stretch=CondensedStretch, weight=NormalWeight, encoding=e, foundry=f, format=g')
  end

  it 'shows empty names when they are nil' do
    font = described_class.new(nil, nil, nil, Magick::NormalStyle, Magick::NormalStretch, 700, nil, nil, nil)

    expect(font.to_s).to eq('name=, description=, family=, style=NormalStyle, stretch=NormalStretch, weight=BoldWeight, encoding=, foundry=, format=')
  end

  it 'converts the weight as an Integer' do
    font = described_class.new('a', 'b', 'c', Magick::NormalStyle, Magick::NormalStretch, 700.0, nil, nil, nil)

    expect(font.to_s).to include('weight=BoldWeight')
  end

  it 'raises TypeError for a member of the wrong type' do
    font = described_class.new('a', 'b', 'c', Magick::NormalStyle, Magick::NormalStretch, '700', nil, nil, nil)
    expect { font.to_s }.to raise_error(TypeError)

    font = described_class.new('a', 'b', 'c', :normal, Magick::NormalStretch, 700, nil, nil, nil)
    expect { font.to_s }.to raise_error(TypeError)

    font = described_class.new('a', 'b', 'c', Magick::NormalStretch, Magick::NormalStyle, 700, nil, nil, nil)
    expect { font.to_s }.to raise_error(TypeError, /expected Magick::StyleType/)
  end

  it 'raises ArgumentError for a negative weight' do
    font = described_class.new('a', 'b', 'c', Magick::NormalStyle, Magick::NormalStretch, -1, nil, nil, nil)

    expect { font.to_s }.to raise_error(ArgumentError, 'weight must be >= 0 (-1 given)')
  end
end
