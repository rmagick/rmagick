RSpec.describe Magick::Image, '#decipher' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    res = res2 = nil
    expect do
      res = @img.encipher 'passphrase'
      res2 = res.decipher 'passphrase'
    end.not_to raise_error
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(@img)
    expect(res.columns).to eq(@img.columns)
    expect(res.rows).to eq(@img.rows)
    expect(res2).to be_instance_of(described_class)
    expect(res2).not_to be(@img)
    expect(res2.columns).to eq(@img.columns)
    expect(res2.rows).to eq(@img.rows)
    expect(res2).to eq(@img)
  end
end
