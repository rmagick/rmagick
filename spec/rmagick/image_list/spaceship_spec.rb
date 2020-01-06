RSpec.describe Magick::ImageList, '#<=>' do
  it 'works' do
    list1 = described_class.new(*FILES[0..9])
    list2 = list1.copy

    expect(list2.scene).to eq(list1.scene)
    expect(list2).to eq(list1)
    list2.scene = 0
    expect(list2).not_to eq(list1)
    list2 = list1.copy
    list2[9] = list2[0]
    expect(list2).not_to eq(list1)
    list2 = list1.copy
    list2 << list1[9]
    expect(list2).not_to eq(list1)

    expect { list1 <=> 2 }.to raise_error(TypeError)
    list2 = described_class.new
    list3 = described_class.new
    expect { list2 <=> list1 }.to raise_error(TypeError)
    expect { list1 <=> list2 }.to raise_error(TypeError)
    expect { list3 <=> list2 }.not_to raise_error
  end
end
