RSpec.describe Magick::ImageList, '#delay' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    expect { image_list.delay }.not_to raise_error
    expect(image_list.delay).to eq(0)
    expect { image_list.delay = 20 }.not_to raise_error
    expect(image_list.delay).to eq(20)
    expect { image_list.delay = 'x' }.to raise_error(ArgumentError)
  end
end
