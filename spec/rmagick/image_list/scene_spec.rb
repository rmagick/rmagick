RSpec.describe Magick::ImageList, '#scene' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    expect { image_list.scene }.not_to raise_error
    expect(image_list.scene).to eq(9)
    expect { image_list.scene = 0 }.not_to raise_error
    expect(image_list.scene).to eq(0)
    expect { image_list.scene = 1 }.not_to raise_error
    expect(image_list.scene).to eq(1)
    expect { image_list.scene = -1 }.to raise_error(IndexError)
    expect { image_list.scene = 1000 }.to raise_error(IndexError)
    expect { image_list.scene = nil }.to raise_error(IndexError)

    # allow nil on empty image_list
    empty_list = described_class.new
    expect { empty_list.scene = nil }.not_to raise_error
  end
end
