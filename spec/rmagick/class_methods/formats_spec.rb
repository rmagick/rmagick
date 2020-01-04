describe Magick, '.formats' do
  it 'works' do
    expect(Magick.formats).to be_instance_of(Hash)
    Magick.formats.each do |f, v|
      expect(f).to be_instance_of(String)
      expect(v).to match(/[\*\+\srw]+/)
    end

    Magick.formats do |f, v|
      expect(f).to be_instance_of(String)
      expect(v).to match(/[\*\+\srw]+/)
    end
  end
end
