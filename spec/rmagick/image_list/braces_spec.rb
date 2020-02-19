RSpec.describe Magick::ImageList, '#[]' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    expect { image_list[0] }.not_to raise_error
    expect(image_list[0]).to be_instance_of(Magick::Image)
    expect(image_list[-1]).to be_instance_of(Magick::Image)
    expect(image_list[0, 1]).to be_instance_of(described_class)
    expect(image_list[0..2]).to be_instance_of(described_class)
    expect(image_list[20]).to be(nil)
  end
end
