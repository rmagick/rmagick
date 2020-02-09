RSpec.describe Magick::Geometry, '#from_s' do
  it 'works' do
    expect(described_class.from_s('').to_s).to eq('')
    expect(described_class.from_s('x').to_s).to eq('')
    expect(described_class.from_s('10').to_s).to eq('10x')
    expect(described_class.from_s('10x').to_s).to eq('10x')
    expect(described_class.from_s('10x20').to_s).to eq('10x20')
    expect(described_class.from_s('10x20+30+40').to_s).to eq('10x20+30+40')
    expect(described_class.from_s('x20+30+40').to_s).to eq('x20+30+40')
    expect(described_class.from_s('+30+40').to_s).to eq('+30+40')
    expect(described_class.from_s('+0+40').to_s).to eq('+0+40')
    expect(described_class.from_s('+30').to_s).to eq('+30+0')

    expect(described_class.from_s('10%x20%+30+40').to_s).to eq('10%x20%+30+40')
    expect(described_class.from_s('x20%+30+40').to_s).to eq('x20%+30+40')

    expect(described_class.from_s('10.2x20.5+30+40').to_s).to eq('10.20x20.50+30+40')
    expect(described_class.from_s('10.2%x20.500%+30+40').to_s).to eq('10.20%x20.50%+30+40')

    expect { described_class.from_s('10x20+') }.to raise_error(ArgumentError)
    expect { described_class.from_s('+30.000+40') }.to raise_error(ArgumentError)
    expect { described_class.from_s('+30.000+40.000') }.to raise_error(ArgumentError)
    expect { described_class.from_s('10x20+30.000+40') }.to raise_error(ArgumentError)
    expect { described_class.from_s('10x20+30.000+40.000') }.to raise_error(ArgumentError)
  end
end
