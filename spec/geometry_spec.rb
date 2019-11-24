RSpec.describe Magick::Geometry do
  describe '#constants' do
    it 'works' do
      expect(Magick::PercentGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::PercentGeometry.to_s).to eq('PercentGeometry')
      expect(Magick::PercentGeometry.to_i).to eq(1)

      expect(Magick::AspectGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::AspectGeometry.to_s).to eq('AspectGeometry')
      expect(Magick::AspectGeometry.to_i).to eq(2)

      expect(Magick::LessGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::LessGeometry.to_s).to eq('LessGeometry')
      expect(Magick::LessGeometry.to_i).to eq(3)

      expect(Magick::GreaterGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::GreaterGeometry.to_s).to eq('GreaterGeometry')
      expect(Magick::GreaterGeometry.to_i).to eq(4)

      expect(Magick::AreaGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::AreaGeometry.to_s).to eq('AreaGeometry')
      expect(Magick::AreaGeometry.to_i).to eq(5)

      expect(Magick::MinimumGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::MinimumGeometry.to_s).to eq('MinimumGeometry')
      expect(Magick::MinimumGeometry.to_i).to eq(6)
    end
  end

  describe '#initialize' do
    it 'works' do
      expect { Magick::Geometry.new(Magick::PercentGeometry) }.to raise_error(ArgumentError)
      expect { Magick::Geometry.new(0, Magick::PercentGeometry) }.to raise_error(ArgumentError)
      expect { Magick::Geometry.new(0, 0, Magick::PercentGeometry) }.to raise_error(ArgumentError)
      expect { Magick::Geometry.new(0, 0, 0, Magick::PercentGeometry) }.to raise_error(ArgumentError)

      expect { Magick::Geometry.new(-1) }.to raise_error(ArgumentError)
      expect { Magick::Geometry.new(0, -1) }.to raise_error(ArgumentError)

      geometry = Magick::Geometry.new
      expect(geometry.width).to eq(0)
      expect(geometry.height).to eq(0)
      expect(geometry.x).to eq(0)
      expect(geometry.y).to eq(0)
      expect(geometry.flag).to be(nil)

      geometry = Magick::Geometry.new(10, 20, 30, 40)
      expect(geometry.width).to eq(10)
      expect(geometry.height).to eq(20)
      expect(geometry.x).to eq(30)
      expect(geometry.y).to eq(40)
    end
  end

  describe '#to_s' do
    it 'works' do
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

  describe '#from_s' do
    it 'works' do
      expect(Magick::Geometry.from_s('').to_s).to eq('')
      expect(Magick::Geometry.from_s('x').to_s).to eq('')
      expect(Magick::Geometry.from_s('10').to_s).to eq('10x')
      expect(Magick::Geometry.from_s('10x').to_s).to eq('10x')
      expect(Magick::Geometry.from_s('10x20').to_s).to eq('10x20')
      expect(Magick::Geometry.from_s('10x20+30+40').to_s).to eq('10x20+30+40')
      expect(Magick::Geometry.from_s('x20+30+40').to_s).to eq('x20+30+40')
      expect(Magick::Geometry.from_s('+30+40').to_s).to eq('+30+40')
      expect(Magick::Geometry.from_s('+0+40').to_s).to eq('+0+40')
      expect(Magick::Geometry.from_s('+30').to_s).to eq('+30+0')

      expect(Magick::Geometry.from_s('10%x20%+30+40').to_s).to eq('10%x20%+30+40')
      expect(Magick::Geometry.from_s('x20%+30+40').to_s).to eq('x20%+30+40')

      expect(Magick::Geometry.from_s('10.2x20.5+30+40').to_s).to eq('10.20x20.50+30+40')
      expect(Magick::Geometry.from_s('10.2%x20.500%+30+40').to_s).to eq('10.20%x20.50%+30+40')

      expect { Magick::Geometry.from_s('10x20+') }.to raise_error(ArgumentError)
      expect { Magick::Geometry.from_s('+30.000+40') }.to raise_error(ArgumentError)
      expect { Magick::Geometry.from_s('+30.000+40.000') }.to raise_error(ArgumentError)
      expect { Magick::Geometry.from_s('10x20+30.000+40') }.to raise_error(ArgumentError)
      expect { Magick::Geometry.from_s('10x20+30.000+40.000') }.to raise_error(ArgumentError)
    end
  end
end
