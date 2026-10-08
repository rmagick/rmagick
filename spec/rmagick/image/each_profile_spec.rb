# frozen_string_literal: true

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

  it 'yields every profile when the block deletes them' do
    image = described_class.new(20, 20)
    image.iptc_profile = 'iptc profile'
    image.add_profile(FIXTURE_PATH + '/cmyk.icm')

    yielded = []
    image.each_profile do |name, value|
      yielded << [name, value]
      image.delete_profile('iptc')
      image.delete_profile('icc')
    end
    expect(yielded.map(&:first)).to contain_exactly('iptc', 'icc')
    expect(yielded.map { |_name, value| value.nil? }).to eq([false, true])
  end

  it 'raises an error when the block destroys the image' do
    image = described_class.new(20, 20)
    image.iptc_profile = 'iptc profile'
    image.add_profile(FIXTURE_PATH + '/cmyk.icm')

    expect { image.each_profile { image.destroy! } }.to raise_error(Magick::DestroyedImageError)
  end
end
