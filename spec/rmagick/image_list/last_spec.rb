RSpec.describe Magick::ImageList, '#last' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    image = Magick::Image.new(5, 5)
    list << image
    image2 = nil
    expect { image2 = list.last }.not_to raise_error
    expect(image2).to be_instance_of(Magick::Image)
    expect(image).to eq(image2)
    image2 = Magick::Image.new(5, 5)
    list << image2
    ilist2 = nil
    expect { ilist2 = list.last(2) }.not_to raise_error
    expect(ilist2).to be_instance_of(described_class)
    expect(ilist2.length).to eq(2)
    expect(ilist2.scene).to eq(1)
    expect(ilist2[0]).to eq(image)
    expect(ilist2[1]).to eq(image2)
  end
end
