RSpec.describe Magick::ImageList, '#select' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    result = list.select { |image| File.basename(image.filename) =~ /Button_2/ }
    expect(result).to be_instance_of(described_class)
    expect(result.length).to eq(1)
    expect(list[2]).to be(result[0])
  end
end
