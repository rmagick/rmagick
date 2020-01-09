RSpec.describe Magick, '.fonts' do
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
