RSpec.describe Magick::ImageList, '#clear' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    expect { image_list.clear }.not_to raise_error
    expect(image_list).to be_instance_of(described_class)
    expect(image_list.length).to eq(0)
    expect(image_list.scene).to be(nil)
  end
end
