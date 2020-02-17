RSpec.describe Magick::ImageList, '#map!' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    image = list[0]
    expect do
      list.map! { image }
    end.not_to raise_error
    expect(list).to be_instance_of(described_class)
    expect { list.map! { 2 } }.to raise_error(ArgumentError)
  end
end
