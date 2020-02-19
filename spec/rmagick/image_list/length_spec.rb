RSpec.describe Magick::ImageList, '#length' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    expect { image_list.length }.not_to raise_error
    expect(image_list.length).to eq(10)
    expect { image_list.length = 2 }.to raise_error(NoMethodError)
  end
end
