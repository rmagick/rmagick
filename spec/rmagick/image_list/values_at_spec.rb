RSpec.describe Magick::ImageList, '#values_at' do
  before do
    @list = described_class.new(*FILES[0..9])
  end

  it 'works' do
    list2 = nil
    expect { list2 = @list.values_at(1, 3, 5) }.not_to raise_error
    expect(list2).to be_instance_of(described_class)
    expect(list2.length).to eq(3)
    expect(list2.scene).to eq(2)
  end
end
