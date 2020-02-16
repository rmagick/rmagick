RSpec.describe Magick::Image, '#each_profile' do
  it 'works' do
    img = described_class.new(20, 20)

    expect(img.each_profile {}).to be(nil)

    img.iptc_profile = 'test profile'
    expect do
      img.each_profile do |name, value|
        expect(name).to eq('iptc')
        expect(value).to eq('test profile')
      end
    end.not_to raise_error
  end
end
