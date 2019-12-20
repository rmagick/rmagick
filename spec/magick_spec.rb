module Magick
  def self._tmpnam_
    @@_tmpnam_
  end
end

class Magick::AlphaChannelOption
  def self.enumerators
    @@enumerators
  end
end

class Magick::AlignType
  def self.enumerators
    @@enumerators
  end
end

class Magick::AnchorType
  def self.enumerators
    @@enumerators
  end
end

RSpec.describe Magick do
  describe '#colors' do
    it 'works' do
      res = nil
      expect { res = Magick.colors }.not_to raise_error
      expect(res).to be_instance_of(Array)
      res.each do |c|
        expect(c).to be_instance_of(Magick::Color)
        expect(c.name).to be_instance_of(String)
        expect(c.compliance).to be_instance_of(Magick::ComplianceType) unless c.compliance.nil?
        expect(c.color).to be_instance_of(Magick::Pixel)
      end
      Magick.colors { |c| expect(c).to be_instance_of(Magick::Color) }
    end
  end

  # Test a few of the @@enumerator arrays in the Enum subclasses.
  # No need to test all of them.
  describe '#enumerators' do
    it 'works' do
      ary = nil
      expect do
        ary = Magick::AlphaChannelOption.enumerators
      end.not_to raise_error
      expect(ary).to be_instance_of(Array)

      expect do
        ary = Magick::AlignType.enumerators
      end.not_to raise_error
      expect(ary).to be_instance_of(Array)
      expect(ary.length).to eq(4)

      expect do
        ary = Magick::AnchorType.enumerators
      end.not_to raise_error
      expect(ary).to be_instance_of(Array)
      expect(ary.length).to eq(3)
    end
  end

  describe '#features' do
    it 'works' do
      res = nil
      expect { res = Magick::Magick_features }.not_to raise_error
      expect(res).to be_instance_of(String)
    end
  end

  describe '#fonts' do
    it 'works' do
      res = nil
      expect { res = Magick.fonts }.not_to raise_error
      expect(res).to be_instance_of(Array)
      res.each do |f|
        expect(f).to be_instance_of(Magick::Font)
        expect(f.name).to be_instance_of(String)
        expect(f.description).to be_instance_of(String) unless f.description.nil?
        expect(f.family).to be_instance_of(String)
        expect(f.style).to be_instance_of(Magick::StyleType) unless f.style.nil?
        expect(f.stretch).to be_instance_of(Magick::StretchType) unless f.stretch.nil?
        expect(f.weight).to be_kind_of(Integer)
        expect(f.encoding).to be_instance_of(String) unless f.encoding.nil?
        expect(f.foundry).to be_instance_of(String) unless f.foundry.nil?
        expect(f.format).to be_instance_of(String) unless f.format.nil?
      end
      Magick.fonts { |f| expect(f).to be_instance_of(Magick::Font) }
    end
  end

  describe '#geometry' do
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
    end
  end

  describe '#init_formats' do
    it 'works' do
      expect(Magick.init_formats).to be_instance_of(Hash)
    end
  end

  describe '#opaque_alpha' do
    it 'works' do
      expect(Magick::OpaqueAlpha).to eq(Magick::QuantumRange)
    end
  end

  describe '#set_log_event_mask' do
    it 'works' do
      expect { Magick.set_log_event_mask('Module,Coder') }.not_to raise_error
      expect { Magick.set_log_event_mask('None') }.not_to raise_error
    end
  end

  describe '#set_log_format' do
    it 'works' do
      expect { Magick.set_log_format('format %d%e%f') }.not_to raise_error
    end
  end

  describe '#limit_resources' do
    it 'works' do
      cur = new = nil

      expect { cur = Magick.limit_resource(:memory, 500) }.not_to raise_error
      expect(cur).to be_kind_of(Integer)
      expect(cur > 1024**2).to be(true)
      expect { new = Magick.limit_resource('memory') }.not_to raise_error
      expect(new).to eq(500)
      Magick.limit_resource(:memory, cur)

      expect { cur = Magick.limit_resource(:map, 3500) }.not_to raise_error
      expect(cur).to be_kind_of(Integer)
      expect(cur > 1024**2).to be(true)
      expect { new = Magick.limit_resource('map') }.not_to raise_error
      expect(new).to eq(3500)
      Magick.limit_resource(:map, cur)

      expect { cur = Magick.limit_resource(:disk, 3 * 1024 * 1024 * 1024) }.not_to raise_error
      expect(cur).to be_kind_of(Integer)
      expect(cur > 1024**2).to be(true)
      expect { new = Magick.limit_resource('disk') }.not_to raise_error
      expect(new).to eq(3_221_225_472)
      Magick.limit_resource(:disk, cur)

      expect { cur = Magick.limit_resource(:file, 500) }.not_to raise_error
      expect(cur).to be_kind_of(Integer)
      expect(cur > 100).to be(true)
      expect { new = Magick.limit_resource('file') }.not_to raise_error
      expect(new).to eq(500)
      Magick.limit_resource(:file, cur)

      expect { cur = Magick.limit_resource(:time, 300) }.not_to raise_error
      expect(cur).to be_kind_of(Integer)
      expect(cur > 300).to be(true)
      expect { new = Magick.limit_resource('time') }.not_to raise_error
      expect(new).to eq(300)
      Magick.limit_resource(:time, cur)

      expect { Magick.limit_resource(:xxx) }.to raise_error(ArgumentError)
      expect { Magick.limit_resource('xxx') }.to raise_error(ArgumentError)
      expect { Magick.limit_resource('map', 3500, 2) }.to raise_error(ArgumentError)
      expect { Magick.limit_resource }.to raise_error(ArgumentError)
    end
  end

  describe '#transparent_alpha' do
    it 'works' do
      expect(Magick::TransparentAlpha).to eq(0)
    end
  end
end
