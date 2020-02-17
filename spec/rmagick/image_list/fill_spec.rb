RSpec.describe Magick::ImageList, '#fill' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image_list2 = image_list.copy
    image = image_list[0].copy

    expect(image_list2.fill(image)).to be_instance_of(described_class)

    image_list2.each { |el| expect(image).to be(el) }

    image_list2 = image_list.copy
    image_list2.fill(image, 0, 3)
    0.upto(2) { |i| expect(image_list2[i]).to be(image) }

    image_list2 = image_list.copy
    image_list2.fill(image, 4..7)
    4.upto(7) { |i| expect(image_list2[i]).to be(image) }

    image_list2 = image_list.copy
    image_list2.fill { |i| image_list2[i] = image }
    image_list2.each { |el| expect(image).to be(el) }

    image_list2 = image_list.copy
    image_list2.fill(0, 3) { |i| image_list2[i] = image }
    0.upto(2) { |i| expect(image_list2[i]).to be(image) }

    expect { image_list2.fill('x', 0) }.to raise_error(ArgumentError)
  end
end
