RSpec.describe Magick::ImageList, '#iterations' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    expect { image_list.iterations }.not_to raise_error
    expect(image_list.iterations).to be_kind_of(Integer)
    expect { image_list.iterations = 20 }.not_to raise_error
    expect(image_list.iterations).to eq(20)
    expect { image_list.iterations = 'x' }.to raise_error(ArgumentError)
  end
end
