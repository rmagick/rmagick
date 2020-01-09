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
end
