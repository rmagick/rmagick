RSpec.describe Magick, '.colors' do
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
