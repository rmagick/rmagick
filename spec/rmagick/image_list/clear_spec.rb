RSpec.describe Magick::ImageList, '#clear' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    expect { list.clear }.not_to raise_error
    expect(list).to be_instance_of(described_class)
    expect(list.length).to eq(0)
    expect(list.scene).to be(nil)
  end
end
