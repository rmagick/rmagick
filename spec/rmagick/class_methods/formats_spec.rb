describe Magick, '.formats' do
  it 'works' do
    expect(described_class.formats).to be_instance_of(Hash)
    described_class.formats.each do |f, v|
      expect(f).to be_instance_of(String)
      expect(v).to match(/[\*\+\srw]+/)
    end

    described_class.formats do |f, v|
      expect(f).to be_instance_of(String)
      expect(v).to match(/[\*\+\srw]+/)
    end
  end
end
