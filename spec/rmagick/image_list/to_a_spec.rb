RSpec.describe Magick::ImageList, '#to_a' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    a = nil
    expect { a = image_list.to_a }.not_to raise_error
    expect(a).to be_instance_of(Array)
    expect(a.length).to eq(10)
  end
end
