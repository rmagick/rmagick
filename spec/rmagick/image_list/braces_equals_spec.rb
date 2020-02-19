RSpec.describe Magick::ImageList, '#[]=' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])
    image = Magick::Image.new(5, 5)

    rv = image_list[0] = image
    expect(rv).to be(image)
    expect(image_list[0]).to be(image)
    expect(image_list.scene).to eq(0)

    # replace 2 images with 1
    image = Magick::Image.new(5, 5)
    rv = image_list[1, 2] = image
    expect(rv).to be(image)
    expect(image_list.length).to eq(9)
    expect(image_list[1]).to be(image)
    expect(image_list.scene).to eq(1)

    # replace 1 image with 2
    image = Magick::Image.new(5, 5)
    image2 = Magick::Image.new(5, 5)
    ary = [image, image2]
    rv = image_list[3, 1] = ary
    expect(rv).to be(ary)
    expect(image_list.length).to eq(10)
    expect(image_list[3]).to be(image)
    expect(image_list[4]).to be(image2)
    expect(image_list.scene).to eq(4)

    image = Magick::Image.new(5, 5)
    rv = image_list[5..6] = image
    expect(rv).to be(image)
    expect(image_list.length).to eq(9)
    expect(image_list[5]).to be(image)
    expect(image_list.scene).to eq(5)

    ary = [image, image]
    rv = image_list[7..8] = ary
    expect(rv).to be(ary)
    expect(image_list.length).to eq(9)
    expect(image_list[7]).to be(image)
    expect(image_list[8]).to be(image)
    expect(image_list.scene).to eq(8)

    rv = image_list[-1] = image
    expect(rv).to be(image)
    expect(image_list.length).to eq(9)
    expect(image_list[8]).to be(image)
    expect(image_list.scene).to eq(8)

    expect { image_list[0] = 1 }.to raise_error(ArgumentError)
    expect { image_list[0, 1] = [1, 2] }.to raise_error(ArgumentError)
    expect { image_list[2..3] = 'x' }.to raise_error(ArgumentError)
  end
end
