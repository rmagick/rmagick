RSpec.describe Magick::ImageList, '#find_all' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    expect do
      res = list.find_all { |img| File.basename(img.filename) =~ /Button_2/ }
      expect(res).to be_instance_of(described_class)
      expect(res.length).to eq(1)
      expect(list[2]).to be(res[0])
    end.not_to raise_error
  end
end
