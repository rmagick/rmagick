RSpec.describe Magick::ImageList, '#[]=' do
  it 'works' do
    list = described_class.new(*FILES[0..9])
    img = Magick::Image.new(5, 5)

    expect do
      rv = list[0] = img
      expect(rv).to be(img)
      expect(list[0]).to be(img)
      expect(list.scene).to eq(0)
    end.not_to raise_error

    # replace 2 images with 1
    expect do
      img = Magick::Image.new(5, 5)
      rv = list[1, 2] = img
      expect(rv).to be(img)
      expect(list.length).to eq(9)
      expect(list[1]).to be(img)
      expect(list.scene).to eq(1)
    end.not_to raise_error

    # replace 1 image with 2
    expect do
      img = Magick::Image.new(5, 5)
      img2 = Magick::Image.new(5, 5)
      ary = [img, img2]
      rv = list[3, 1] = ary
      expect(rv).to be(ary)
      expect(list.length).to eq(10)
      expect(list[3]).to be(img)
      expect(list[4]).to be(img2)
      expect(list.scene).to eq(4)
    end.not_to raise_error

    expect do
      img = Magick::Image.new(5, 5)
      rv = list[5..6] = img
      expect(rv).to be(img)
      expect(list.length).to eq(9)
      expect(list[5]).to be(img)
      expect(list.scene).to eq(5)
    end.not_to raise_error

    expect do
      ary = [img, img]
      rv = list[7..8] = ary
      expect(rv).to be(ary)
      expect(list.length).to eq(9)
      expect(list[7]).to be(img)
      expect(list[8]).to be(img)
      expect(list.scene).to eq(8)
    end.not_to raise_error

    expect do
      rv = list[-1] = img
      expect(rv).to be(img)
      expect(list.length).to eq(9)
      expect(list[8]).to be(img)
      expect(list.scene).to eq(8)
    end.not_to raise_error

    expect { list[0] = 1 }.to raise_error(ArgumentError)
    expect { list[0, 1] = [1, 2] }.to raise_error(ArgumentError)
    expect { list[2..3] = 'x' }.to raise_error(ArgumentError)
  end
end
