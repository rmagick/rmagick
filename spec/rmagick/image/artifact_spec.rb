# frozen_string_literal: true

RSpec.describe Magick::Image, '#artifact' do
  it 'returns the value set by Image#define' do
    image = described_class.new(10, 10)

    expect(image.artifact('mykey')).to be(nil)

    image.define('mykey', 'myvalue')
    expect(image.artifact('mykey')).to eq('myvalue')
    expect(image.artifact(:mykey)).to eq('myvalue')

    image.undefine('mykey')
    expect(image.artifact('mykey')).to be(nil)
  end

  it 'returns the value set by Image::Info#define' do
    image = described_class.new(10, 10)
    image.to_blob do |info|
      info.format = 'PNG'
      info.define('reg', 'probe', 'HELLOARTIFACT')
    end

    expect(image.artifact('reg:probe')).to eq('HELLOARTIFACT')
  end

  it 'raises an error on a destroyed image' do
    image = described_class.new(10, 10)
    image.destroy!

    expect { image.artifact('mykey') }.to raise_error(Magick::DestroyedImageError)
  end
end
