RSpec.describe Magick::Geometry, '#to_s' do
  it 'works' do
    g = nil
    gs = nil
    g2 = nil
    expect { g = Magick::Geometry.new }.not_to raise_error
    expect { gs = g.to_s }.not_to raise_error
    expect(gs).to eq('')

    g = Magick::Geometry.new(40)
    gs = g.to_s
    expect(gs).to eq('40x')

    expect { g2 = Magick::Geometry.from_s(gs) }.not_to raise_error
    gs2 = g2.to_s
    expect(gs2).to eq(gs)

    g = Magick::Geometry.new(40, 50)
    gs = g.to_s
    expect(gs).to eq('40x50')

    expect { g2 = Magick::Geometry.from_s(gs) }.not_to raise_error
    gs2 = g2.to_s
    expect(gs2).to eq(gs)

    g = Magick::Geometry.new(40, 50, 10)
    gs = g.to_s
    expect(gs).to eq('40x50+10+0')

    expect { g2 = Magick::Geometry.from_s(gs) }.not_to raise_error
    gs2 = g2.to_s
    expect(gs2).to eq(gs)

    g = Magick::Geometry.new(40, 50, 10, -15)
    gs = g.to_s
    expect(gs).to eq('40x50+10-15')

    expect { g2 = Magick::Geometry.from_s(gs) }.not_to raise_error
    gs2 = g2.to_s
    expect(gs2).to eq(gs)

    g = Magick::Geometry.new(40, 50, 0, 0, Magick::AreaGeometry)
    gs = g.to_s
    expect(gs).to eq('40x50@')

    expect { g2 = Magick::Geometry.from_s(gs) }.not_to raise_error
    gs2 = g2.to_s
    expect(gs2).to eq(gs)

    g = Magick::Geometry.new(40, 50, 0, 0, Magick::AspectGeometry)
    gs = g.to_s
    expect(gs).to eq('40x50!')

    expect { g2 = Magick::Geometry.from_s(gs) }.not_to raise_error
    gs2 = g2.to_s
    expect(gs2).to eq(gs)

    g = Magick::Geometry.new(40, 50, 0, 0, Magick::LessGeometry)
    gs = g.to_s
    expect(gs).to eq('40x50<')

    expect { g2 = Magick::Geometry.from_s(gs) }.not_to raise_error
    gs2 = g2.to_s
    expect(gs2).to eq(gs)

    g = Magick::Geometry.new(40, 50, 0, 0, Magick::GreaterGeometry)
    gs = g.to_s
    expect(gs).to eq('40x50>')

    expect { g2 = Magick::Geometry.from_s(gs) }.not_to raise_error
    gs2 = g2.to_s
    expect(gs2).to eq(gs)

    g = Magick::Geometry.new(40, 50, 0, 0, Magick::MinimumGeometry)
    gs = g.to_s
    expect(gs).to eq('40x50^')

    expect { g2 = Magick::Geometry.from_s(gs) }.not_to raise_error
    gs2 = g2.to_s
    expect(gs2).to eq(gs)

    g = Magick::Geometry.new(40, 0, 0, 0, Magick::PercentGeometry)
    gs = g.to_s
    expect(gs).to eq('40%')

    expect { g2 = Magick::Geometry.from_s(gs) }.not_to raise_error
    gs2 = g2.to_s
    expect(gs2).to eq(gs)

    g = Magick::Geometry.new(40, 60, 0, 0, Magick::PercentGeometry)
    gs = g.to_s
    expect(gs).to eq('40%x60%')

    expect { g2 = Magick::Geometry.from_s(gs) }.not_to raise_error
    gs2 = g2.to_s
    expect(gs2).to eq(gs)

    g = Magick::Geometry.new(40, 60, 10, 0, Magick::PercentGeometry)
    gs = g.to_s
    expect(gs).to eq('40%x60%+10+0')

    expect { g2 = Magick::Geometry.from_s(gs) }.not_to raise_error
    gs2 = g2.to_s
    expect(gs2).to eq(gs)

    g = Magick::Geometry.new(40, 60, 10, 20, Magick::PercentGeometry)
    gs = g.to_s
    expect(gs).to eq('40%x60%+10+20')

    expect { g2 = Magick::Geometry.from_s(gs) }.not_to raise_error
    gs2 = g2.to_s
    expect(gs2).to eq(gs)

    g = Magick::Geometry.new(40.5, 60.75)
    gs = g.to_s
    expect(gs).to eq('40.50x60.75')

    expect { g2 = Magick::Geometry.from_s(gs) }.not_to raise_error
    gs2 = g2.to_s
    expect(gs2).to eq(gs)

    g = Magick::Geometry.new(40.5, 60.75, 0, 0, Magick::PercentGeometry)
    gs = g.to_s
    expect(gs).to eq('40.50%x60.75%')

    expect { g2 = Magick::Geometry.from_s(gs) }.not_to raise_error
    gs2 = g2.to_s
    expect(gs2).to eq(gs)

    g = Magick::Geometry.new(0, 0, 10, 20)
    gs = g.to_s
    expect(gs).to eq('+10+20')

    expect { g2 = Magick::Geometry.from_s(gs) }.not_to raise_error
    gs2 = g2.to_s
    expect(gs2).to eq(gs)

    g = Magick::Geometry.new(0, 0, 10)
    gs = g.to_s
    expect(gs).to eq('+10+0')

    expect { g2 = Magick::Geometry.from_s(gs) }.not_to raise_error
    gs2 = g2.to_s
    expect(gs2).to eq(gs)

    # check behavior with empty string argument
    expect { g = Magick::Geometry.from_s('') }.not_to raise_error
    expect(g.to_s).to eq('')

    expect { Magick::Geometry.new(Magick::AreaGeometry) }.to raise_error(ArgumentError)
    expect { Magick::Geometry.new(40, Magick::AreaGeometry) }.to raise_error(ArgumentError)
    expect { Magick::Geometry.new(40, 20, Magick::AreaGeometry) }.to raise_error(ArgumentError)
    expect { Magick::Geometry.new(40, 20, 10, Magick::AreaGeometry) }.to raise_error(ArgumentError)

    expect(Magick::Geometry.new.to_s).to eq('')
    expect(Magick::Geometry.new(10).to_s).to eq('10x')
    expect(Magick::Geometry.new(10, 20).to_s).to eq('10x20')
    expect(Magick::Geometry.new(10, 20, 30).to_s).to eq('10x20+30+0')
    expect(Magick::Geometry.new(10, 20, 30, 40).to_s).to eq('10x20+30+40')
    expect(Magick::Geometry.new(0, 20, 30, 40).to_s).to eq('x20+30+40')
    expect(Magick::Geometry.new(0, 0, 30, 40).to_s).to eq('+30+40')
    expect(Magick::Geometry.new(0, 0, 0, 40).to_s).to eq('+0+40')

    expect(Magick::Geometry.new(10, 20, 30, 40, Magick::PercentGeometry).to_s).to eq('10%x20%+30+40')
    expect(Magick::Geometry.new(0, 20, 30, 40, Magick::PercentGeometry).to_s).to eq('x20%+30+40')

    expect(Magick::Geometry.new(10.2, 20.5, 30, 40).to_s).to eq('10.20x20.50+30+40')
    expect(Magick::Geometry.new(10.2, 20.5, 30, 40, Magick::PercentGeometry).to_s).to eq('10.20%x20.50%+30+40')
  end
end
