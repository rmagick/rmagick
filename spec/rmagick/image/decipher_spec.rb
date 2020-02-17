RSpec.describe Magick::Image, '#decipher' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.encipher 'passphrase'
    res2 = result.decipher 'passphrase'

    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)
    expect(result.columns).to eq(image.columns)
    expect(result.rows).to eq(image.rows)
    expect(res2).to be_instance_of(described_class)
    expect(res2).not_to be(image)
    expect(res2.columns).to eq(image.columns)
    expect(res2.rows).to eq(image.rows)
    expect(res2).to eq(image)
  end
end
