RSpec.describe Magick::ImageList, '#[]' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    expect { list[0] }.not_to raise_error
    expect(list[0]).to be_instance_of(Magick::Image)
    expect(list[-1]).to be_instance_of(Magick::Image)
    expect(list[0, 1]).to be_instance_of(described_class)
    expect(list[0..2]).to be_instance_of(described_class)
    expect(list[20]).to be(nil)
  end
end
