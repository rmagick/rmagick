RSpec.describe Magick::Image, '#decipher' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.encipher 'passphrase'
    res2 = res.decipher 'passphrase'

    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)
    expect(res.columns).to eq(image.columns)
    expect(res.rows).to eq(image.rows)
    expect(res2).to be_instance_of(described_class)
    expect(res2).not_to be(image)
    expect(res2.columns).to eq(image.columns)
    expect(res2.rows).to eq(image.rows)
    expect(res2).to eq(image)
  end
end
