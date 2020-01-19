RSpec.describe Magick do
  describe '::Magick_features' do
    it 'works' do
      res = nil
      expect { res = Magick::Magick_features }.not_to raise_error
      expect(res).to be_instance_of(String)
    end
  end

  describe '::OpaqueAlpha' do
    it 'works' do
      expect(Magick::OpaqueAlpha).to eq(Magick::QuantumRange)
    end
  end

  describe '::TransparentAlpha' do
    it 'works' do
      expect(Magick::TransparentAlpha).to eq(0)
    end
  end

  describe '::PercentGeometry' do
    it 'works' do
      expect(Magick::PercentGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::PercentGeometry.to_s).to eq('PercentGeometry')
      expect(Magick::PercentGeometry.to_i).to eq(1)
    end
  end

  describe '::AspectGeometry' do
    it 'works' do
      expect(Magick::AspectGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::AspectGeometry.to_s).to eq('AspectGeometry')
      expect(Magick::AspectGeometry.to_i).to eq(2)
    end
  end

  describe '::LessGeometry' do
    it 'works' do
      expect(Magick::LessGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::LessGeometry.to_s).to eq('LessGeometry')
      expect(Magick::LessGeometry.to_i).to eq(3)
    end
  end

  describe '::GreaterGeometry' do
    it 'works' do
      expect(Magick::GreaterGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::GreaterGeometry.to_s).to eq('GreaterGeometry')
      expect(Magick::GreaterGeometry.to_i).to eq(4)
    end
  end

  describe '::AreaGeometry' do
    it 'works' do
      expect(Magick::AreaGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::AreaGeometry.to_s).to eq('AreaGeometry')
      expect(Magick::AreaGeometry.to_i).to eq(5)
    end
  end

  describe '::MinimumGeometry' do
    it 'works' do
      expect(Magick::MinimumGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::MinimumGeometry.to_s).to eq('MinimumGeometry')
      expect(Magick::MinimumGeometry.to_i).to eq(6)
    end
  end
end
