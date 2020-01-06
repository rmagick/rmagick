RSpec.describe Magick::ImageList, '#last' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    img = Magick::Image.new(5, 5)
    list << img
    img2 = nil
    expect { img2 = list.last }.not_to raise_error
    expect(img2).to be_instance_of(Magick::Image)
    expect(img).to eq(img2)
    img2 = Magick::Image.new(5, 5)
    list << img2
    ilist2 = nil
    expect { ilist2 = list.last(2) }.not_to raise_error
    expect(ilist2).to be_instance_of(described_class)
    expect(ilist2.length).to eq(2)
    expect(ilist2.scene).to eq(1)
    expect(ilist2[0]).to eq(img)
    expect(ilist2[1]).to eq(img2)
  end
end
