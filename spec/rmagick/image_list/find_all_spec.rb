RSpec.describe Magick::ImageList, '#find_all' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    res = list.find_all { |image| File.basename(image.filename) =~ /Button_2/ }
    expect(res).to be_instance_of(described_class)
    expect(res.length).to eq(1)
    expect(list[2]).to be(res[0])
  end
end
