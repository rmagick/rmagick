RSpec.describe Magick::Image, '#each_profile' do
  it 'works' do
    image = described_class.new(20, 20)

    expect(image.each_profile {}).to be(nil)

    image.iptc_profile = 'test profile'
    image.each_profile do |name, value|
      expect(name).to eq('iptc')
      expect(value).to eq('test profile')
    end
  end
end
