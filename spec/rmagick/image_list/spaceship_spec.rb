RSpec.describe Magick::ImageList, '#<=>' do
  it 'works' do
    image_list1 = described_class.new(*FILES[0..9])
    image_list2 = image_list1.copy

    expect(image_list2.scene).to eq(image_list1.scene)
    expect(image_list2).to eq(image_list1)
    image_list2.scene = 0
    expect(image_list2).not_to eq(image_list1)
    image_list2 = image_list1.copy
    image_list2[9] = image_list2[0]
    expect(image_list2).not_to eq(image_list1)
    image_list2 = image_list1.copy
    image_list2 << image_list1[9]
    expect(image_list2).not_to eq(image_list1)

    expect { image_list1 <=> 2 }.to raise_error(TypeError)
    image_list2 = described_class.new
    image_list3 = described_class.new
    expect { image_list2 <=> image_list1 }.to raise_error(TypeError)
    expect { image_list1 <=> image_list2 }.to raise_error(TypeError)
    expect { image_list3 <=> image_list2 }.not_to raise_error
  end
end
