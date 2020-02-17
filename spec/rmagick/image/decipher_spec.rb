RSpec.describe Magick::Image, '#decipher' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.encipher 'passphrase'
    res2 = res.decipher 'passphrase'

    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(img)
    expect(res.columns).to eq(img.columns)
    expect(res.rows).to eq(img.rows)
    expect(res2).to be_instance_of(described_class)
    expect(res2).not_to be(img)
    expect(res2.columns).to eq(img.columns)
    expect(res2.rows).to eq(img.rows)
    expect(res2).to eq(img)
  end
end
