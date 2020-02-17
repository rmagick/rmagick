RSpec.describe Magick::ImageList, '#ticks_per_second' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    expect { image_list.ticks_per_second }.not_to raise_error
    expect(image_list.ticks_per_second).to eq(100)
    expect { image_list.ticks_per_second = 1000 }.not_to raise_error
    expect(image_list.ticks_per_second).to eq(1000)
    expect { image_list.ticks_per_second = 'x' }.to raise_error(ArgumentError)
  end
end
